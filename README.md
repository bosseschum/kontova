# KONTOVA

Eine webbasierte Kassenverwaltung für Vereine – gebaut mit Ruby on Rails.

## Features

### 🍺 Kiosk
- Selbstbedienung am Terminal oder Smartphone
- Mitglieder buchen Getränke per PIN
- Warenkorb mit automatischem Kastenpreis
- GiroCode QR-Code für Überweisungen per Banking-App

### 💰 Kassenwart
- Mitgliederverwaltung mit Rollenmodell
- Transaktionen buchen (Einzahlungen, Auslagen, Mitgliedsbeiträge)
- Transaktionshistorie pro Mitglied filterbar
- Antragsbearbeitung mit Belegprüfung
- Automatischer halbjährlicher Mitgliedsbeitrag
- Einstellungen per UI konfigurierbar (IBAN, BIC, Beitragshöhen)

### 📦 Getränkewart
- Produktverwaltung mit Einzel- und Kastenpreisen
- Einkäufe erfassen
- Inventur mit Soll/Ist-Vergleich und Schwundanalyse

### 👤 Mitgliederbereich
- Eigener Saldo und Transaktionshistorie
- Auslagenerstattung beantragen mit Belegupload
- E-Mail-Benachrichtigungen bei Antragsentscheidung

### ⚡ Super Admin
- Mehrere Vereine (Multi-Tenancy) per Subdomain
- Organisationen anlegen und verwalten
- Zentrales Dashboard

### 🤖 Automatisierung
- Halbjährlicher Mitgliedsbeitrag per Cronjob
- Monatlicher Kontoauszug per E-Mail

---

## Technischer Stack

| Komponente | Technologie |
|---|---|
| Framework | Ruby on Rails 8.1 |
| Datenbank | PostgreSQL (Production), SQLite (Development + Test) |
| Styling | Tailwind CSS – Dark Theme |
| Authentifizierung | Devise |
| Autorisierung | Pundit |
| Datei-Uploads | ActiveStorage |
| Deployment | Kamal |
| SSL | Let's Encrypt |

---

## Rollenmodell

| Rolle | Zugang |
|---|---|
| `member` | Kiosk + Mitgliederbereich |
| `treasurer` | Kassenwart-Dashboard |
| `inventory_manager` | Inventur-Dashboard |
| `super_admin` | Alle Organisationen verwalten |

---

## Multi-Tenancy

Mitglieder, Produkte, Transaktionen und Einstellungen sind einer Organisation
zugeordnet. Auf `/` wird die Organisation `showcase` angezeigt.

---

## Installation (Development)

### Voraussetzungen

- Ruby 3.4.8 via rbenv
- Node.js
- SQLite

### Setup

```bash
# Repository klonen
git clone https://github.com/bosseschum/kontova.git
cd kontova

# Abhängigkeiten
bundle install

# SQLite-Datenbank, Migrationen und Showcase-Daten einrichten
bin/rails db:prepare
bin/rails db:seed

# CSS bauen
bin/rails tailwindcss:build

# Server starten
bin/dev
```

Der Seed ist idempotent und legt lokale Demo-Daten in der Development-Umgebung an.

### Demo-Zugänge

- Kassenwart: `kasse@example.com` / `password`
- Mitglied: `mitglied@example.com` / `password`, Kiosk-PIN `1234`
- Super-Admin: `admin@example.com` / `password`

Diese Demo-Konten werden ausschließlich in der Development-Umgebung angelegt.
Ändere die Passwörter, bevor du die Anwendung öffentlich zugänglich machst.

### Tests ausführen

```bash
bin/rails test
```

---

## Konfiguration

Nach der Installation als Kassenwart einloggen und unter **Einstellungen** konfigurieren:

| Einstellung | Beschreibung |
|---|---|
| Vereinsname | Wird in E-Mails und QR-Codes angezeigt |
| IBAN | Bankverbindung für GiroCode |
| BIC | Bankleitzahl für GiroCode |
| Standardbeitrag | Halbjährlicher Mitgliedsbeitrag in Cent |
| Beitrag Vereinsheim | Erhöhter Beitrag für Bewohner in Cent |

---

## Cronjobs

```bash
# Mitgliedsbeitrag buchen – 31. März und 30. September
rails members:charge_fees

# Kontoauszug per E-Mail – 1. jeden Monats
rails members:send_invoices
```

Crontab-Beispiel:

```
0 8 31 3 * cd /var/www/kontova && rails members:charge_fees
0 8 30 9 * cd /var/www/kontova && rails members:charge_fees
0 9 1  * * cd /var/www/kontova && rails members:send_invoices
```

---

## Deployment (Production)

### Voraussetzungen

- VPS (z.B. Hetzner CX22)
- Domain `kontova.de`
- Docker auf dem VPS
- Kamal (`gem install kamal`)

### Umgebungsvariablen

```bash
# .env (nicht ins Git!)
RAILS_ENV=production
DATABASE_URL=postgresql://user:password@localhost/kontova_production
MAIL_USERNAME=kasse@mailbox.org
MAIL_PASSWORD=apppasswort
APP_HOST=kontova.de
RAILS_MASTER_KEY=<Inhalt von config/master.key>
```

### Deployment

```bash
# Erstes Deployment
kamal setup
kamal deploy

# Updates einspielen
kamal deploy
```

---

## Lokale Entwicklung mit Subdomains

Auf `http://localhost:3000` wird die Seed-Organisation `showcase` geöffnet.
Um weitere Organisationen lokal per Subdomain zu testen, `/etc/hosts` anpassen
und die Organisationen mit passenden Subdomains in der Datenbank anlegen:

```
127.0.0.1 vereina.localhost
127.0.0.1 vereinb.localhost
```

Dann im Browser:
- `http://vereina.localhost:3000`
- `http://vereinb.localhost:3000`

---

## Lizenz

Copyright (c) 2026 Bosse Schumacher. Alle Rechte vorbehalten.
Siehe [LICENSE](LICENSE) für weitere Informationen.
