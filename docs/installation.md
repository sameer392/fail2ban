# Installation

## One-Liner Install (from GitHub)

```bash
# From latest release (attach install.sh as release asset when creating a release)
curl -sSL https://github.com/sameer392/fail2ban-whm/releases/latest/download/install.sh | bash

# From main branch (works immediately, no release needed)
curl -sSL https://raw.githubusercontent.com/sameer392/fail2ban-whm/main/install.sh | bash
```

Install a specific version (with releases):
```bash
curl -sSL https://github.com/sameer392/fail2ban-whm/releases/latest/download/install.sh | bash -s v1.0.0
```

The bootstrap script downloads the full source archive and runs `scripts/install.sh`.

## Full Installation (from local clone)

```bash
cd /root/fail2ban
./scripts/install.sh
```

**What it does:**
- Copies source to `/usr/share/fail2ban/` (permanent location)
- Installs fail2ban packages (dnf/yum)
- Deploys config to `/etc/fail2ban/`
- Installs libmaxminddb for GeoIP
- Sets up IP2Location LITE DB1 for country lookup
- Installs logrotate config for fail2ban.log
- Enables and starts fail2ban
- **Installs WHM plugin** if cPanel is detected (no cPanel restart needed)
- You may remove `/root/fail2ban` after install

## Config Deploy Only (fail2ban already installed)

```bash
/usr/share/fail2ban/scripts/update.sh
```

Copies filters, jails, actions, scripts, and logrotate config from `/usr/share/fail2ban/` to `/etc/fail2ban/`, updates the WHM plugin, and restarts fail2ban. Does not restart cPanel.

## Update from GitHub

```bash
/usr/share/fail2ban/scripts/update-from-github.sh v1.0.1
```

Downloads the release by tag from GitHub's auto-generated source archive, installs to `/usr/share/fail2ban/`, restores user configs (whitelist-ips.conf, whitelist-countries.conf, etc.), and runs update.sh. Also available via WHM → Fail2Ban Manager → Update tab.

## Uninstall

```bash
# Remove only custom config (keep fail2ban service)
/usr/share/fail2ban/scripts/uninstall.sh

# Full removal: config, packages, WHM plugin, /usr/share/fail2ban/
/usr/share/fail2ban/scripts/uninstall.sh --purge
```
