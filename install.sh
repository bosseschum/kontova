#!/bin/bash
# vereinskasse-install.sh
# Vereinskasse – Automatisches Setup-Script für Arch Linux

set -e

echo "================================"
echo "  Vereinskasse Install-Script"
echo "================================"
echo ""

# Konfiguration abfragen
read -p "Kassenwart Name: " KASSENWART_NAME
read -p "Kassenwart E-Mail: " KASSENWART_EMAIL
read -sp "Kassenwart Passwort: " KASSENWART_PASSWORT
echo ""
read -p "Kassenwart PIN (4 Ziffern): " KASSENWART_PIN
echo ""
read -p "SMTP E-Mail (z.B. kasse@mailbox.org): " MAIL_USERNAME
read -sp "SMTP Passwort: " MAIL_PASSWORD
echo ""
read -p "GitHub Repo URL: " REPO_URL
echo ""

echo "=== Phase 1: System-Pakete ==="
sudo pacman -Sy --noconfirm \
  git base-devel libyaml rbenv ruby-build \
  xorg-server xorg-xinit openbox chromium \
  nodejs npm openssh cronie tailscale

echo ""
echo "=== Phase 2: SSH aktivieren ==="
sudo systemctl enable --now sshd
echo "SSH aktiv. IP-Adresse:"
ip addr show | grep "inet " | grep -v 127.0.0.1

echo ""
echo "=== Phase 3: rbenv & Ruby ==="
if ! grep -q 'rbenv init' ~/.bashrc; then
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc
fi
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

rbenv install 3.4.8 --skip-existing
rbenv global 3.4.8
gem install bundler rails --no-document

echo ""
echo "=== Phase 4: App installieren ==="
cd ~
git clone "$REPO_URL" vereinskasse
cd vereinskasse

# .env anlegen
cat > .env << EOF
MAIL_USERNAME=$MAIL_USERNAME
MAIL_PASSWORD=$MAIL_PASSWORD
EOF
chmod 600 .env

# Gems installieren
bundle install

source ~/.bashrc
gem install rails

SECRET=$(cd vereinskasse && RAILS_ENV=production rails secret)
echo "SECRET_KEY_BASE=$SECRET" >> .env

# CSS bauen
RAILS_ENV=production rails tailwindcss:build

# Datenbank
RAILS_ENV=production rails db:migrate

# Ersten Kassenwart anlegen
RAILS_ENV=production rails runner "
Member.create!(
  display_name: '$KASSENWART_NAME',
  email: '$KASSENWART_EMAIL',
  password: '$KASSENWART_PASSWORT',
  role: :treasurer,
  pin: '$KASSENWART_PIN',
  pays_fee: false
)
puts 'Kassenwart angelegt!'
"

echo ""
echo "=== Phase 5: systemd Service ==="
sudo tee /etc/systemd/system/vereinskasse.service > /dev/null << EOF
[Unit]
Description=Vereinskasse Rails App
After=network.target

[Service]
User=$USER
WorkingDirectory=$HOME/vereinskasse
Environment=RAILS_ENV=production
EnvironmentFile=$HOME/vereinskasse/.env
ExecStart=$HOME/.rbenv/shims/rails server -b 127.0.0.1 -p 3000
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable vereinskasse
sudo systemctl start vereinskasse

# Kurz warten und prüfen
sleep 3
if sudo systemctl is-active --quiet vereinskasse; then
  echo "Rails-Server läuft!"
else
  echo "FEHLER: Rails-Server konnte nicht gestartet werden."
  sudo systemctl status vereinskasse
  exit 1
fi

echo ""
echo "=== Phase 6: Cronjob-Scripts ==="
mkdir -p ~/vereinskasse/bin

cat > ~/vereinskasse/bin/charge_fees.sh << EOF
#!/bin/bash
export PATH="\$HOME/.rbenv/bin:\$PATH"
eval "\$(rbenv init -)"
cd $HOME/vereinskasse
RAILS_ENV=production rails members:charge_fees >> log/cron.log 2>&1
EOF

cat > ~/vereinskasse/bin/send_invoices.sh << EOF
#!/bin/bash
export PATH="\$HOME/.rbenv/bin:\$PATH"
eval "\$(rbenv init -)"
cd $HOME/vereinskasse
RAILS_ENV=production rails members:send_invoices >> log/cron.log 2>&1
EOF

cat > ~/vereinskasse/bin/update.sh << EOF
#!/bin/bash
# Vereinskasse Update-Script
set -e

echo "=== Vereinskasse Update ==="
cd $HOME/vereinskasse

git pull origin main
bundle install
RAILS_ENV=production rails tailwindcss:build
RAILS_ENV=production rails db:migrate
sudo systemctl restart vereinskasse

echo "Update abgeschlossen!"
EOF

chmod +x ~/vereinskasse/bin/charge_fees.sh
chmod +x ~/vereinskasse/bin/send_invoices.sh
chmod +x ~/vereinskasse/bin/update.sh

echo ""
echo "=== Phase 7: Cronjobs ==="
sudo systemctl enable --now cronie

(crontab -l 2>/dev/null; cat << EOF
# Mitgliedsbeitrag – 31. März und 30. September
0 8 31 3 * $HOME/vereinskasse/bin/charge_fees.sh
0 8 30 9 * $HOME/vereinskasse/bin/charge_fees.sh
# Kontoauszug – 1. jeden Monats
0 9 1 * * $HOME/vereinskasse/bin/send_invoices.sh
EOF
) | crontab -

echo ""
echo "=== Phase 8: Kiosk-Modus ==="
mkdir -p ~/.config/openbox

cat > ~/.config/openbox/autostart << EOF
# Warten bis Rails gestartet ist
sleep 5 && chromium \
  --kiosk \
  --noerrdialogs \
  --disable-infobars \
  --disable-session-crashed-bubble \
  --check-for-update-interval=31536000 \
  --no-first-run \
  http://localhost:3000 &
EOF

# Nur auf TTY1 automatisch X starten
if ! grep -q 'startx' ~/.bash_profile; then
  cat >> ~/.bash_profile << EOF

# Kiosk-Modus nur auf TTY1
if [ -z "\$DISPLAY" ] && [ "\$XDG_VTNR" = "1" ]; then
  startx
fi
EOF
fi

echo ""
echo "=== Phase 9: Tailscale ==="
sudo systemctl enable --now tailscaled
echo ""
echo "Tailscale muss manuell verbunden werden:"
echo "  sudo tailscale up"

echo ""
echo "================================"
echo "  Installation abgeschlossen!"
echo "================================"
echo ""
echo "Nächste Schritte:"
echo ""
echo "1. Tailscale verbinden:"
echo "   sudo tailscale up"
echo ""
echo "2. System neu starten:"
echo "   sudo reboot"
echo "   → Kiosk startet automatisch auf TTY1"
echo "   → TTY2+ bleiben als Notfall-Terminal (Ctrl+Alt+F2)"
echo ""
echo "3. Als Kassenwart einloggen und unter 'Einstellungen' eintragen:"
echo "   - Vereinsname, IBAN, BIC (für QR-Code)"
echo "   - Mitgliedsbeitrag Beträge"
echo ""
echo "4. Updates einspielen mit:"
echo "   ~/vereinskasse/bin/update.sh"
echo "================================"
