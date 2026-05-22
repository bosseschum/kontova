# Vereinskasse

Eine webbasierte Kassenverwaltung für Vereine – gebaut mit Ruby on Rails.

## Features

### 🍺 Kiosk
- Selbstbedienung am Terminal oder Smartphone
- Mitglieder buchen Getränke per PIN
- Warenkorb mit automatischem Kastenpreis
- Mischkästen konfigurierbar
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
- Mischkästen konfigurieren

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
| Datenbank | PostgreSQL (Production), SQLite (Development) |
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

Jeder Verein erhält eine eigene Subdomain:

```
vereina.vereinskasse.de
vereinb.vereinskasse.de
```

Daten sind vollständig getrennt – Mitglieder, Produkte, Transaktionen
und Einstellungen gehören immer zu einer Organisation.

---

## Installation (Development)

### Voraussetzungen

- Ruby 3.4.8 via rbenv
- Node.js
- SQLite

### Setup

```bash
# Repository klonen
git clone https://github.com/deinname/vereinskasse.git
cd vereinskasse

# Abhängigkeiten
bundle install

# Umgebungsvariablen
cp .env.example .env
# .env bearbeiten

# Datenbank
rails db:migrate

# CSS bauen
rails tailwindcss:build

# Server starten
bin/dev
```

---

## Erste Organisation und Accounts anlegen

```ruby
rails console

org = Organization.create!(
  name: "Mein Verein",
  subdomain: "meinverein",
  active: true
)

# Super-Admin (ohne Organisation)
Member.create!(
  display_name: "Admin",
  email: "admin@example.com",
  password: "sicherespasswort",
  super_admin: true,
  pin: "1234"
)

# Kassenwart für die Organisation
Member.create!(
  display_name: "Kassenwart",
  email: "kasse@example.com",
  password: "sicherespasswort",
  role: :treasurer,
  organization: org,
  pin: "5678",
  pays_fee: false
)
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
0 8 31 3 * cd /var/www/vereinskasse && rails members:charge_fees
0 8 30 9 * cd /var/www/vereinskasse && rails members:charge_fees
0 9 1  * * cd /var/www/vereinskasse && rails members:send_invoices
```

---

## Deployment (Production)

### Voraussetzungen

- VPS (z.B. Hetzner CX22)
- Domain mit Wildcard-DNS (`*.vereinskasse.de`)
- Docker auf dem VPS
- Kamal (`gem install kamal`)

### Umgebungsvariablen

```bash
# .env (nicht ins Git!)
RAILS_ENV=production
DATABASE_URL=postgresql://user:password@localhost/vereinskasse_production
MAIL_USERNAME=kasse@mailbox.org
MAIL_PASSWORD=apppasswort
APP_HOST=vereinskasse.de
```

### Deployment

```bash
# Erstes Deployment
kamal setup
kamal deploy

# Updates einspielen
kamal deploy
```

### Neue Organisation anlegen

```ruby
kamal console

org = Organization.create!(
  name: "Neuer Verein",
  subdomain: "neuerverein",
  active: true
)

Member.create!(
  display_name: "Kassenwart",
  email: "kasse@neuerverein.de",
  password: SecureRandom.hex(8),
  role: :treasurer,
  organization: org,
  pin: rand(1000..9999).to_s,
  pays_fee: false
)
```

---

## Lokale Entwicklung mit Subdomains

Um Multi-Tenancy lokal zu testen, `/etc/hosts` anpassen:

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
