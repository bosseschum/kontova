#!/bin/bash
# update.sh

set -e

echo "=== KONTOVA Update ==="

cd ~/vereinskasse

# Änderungen holen
git pull origin main

# Neue Gems installieren
bundle install

# CSS neu bauen
RAILS_ENV=production rails tailwindcss:build

# Migrationen ausführen
RAILS_ENV=production rails db:migrate

# Server neu starten
sudo systemctl restart vereinskasse

echo "Update abgeschlossen!"
