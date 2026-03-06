# Installation

## Full Installation (fail2ban not yet installed)

```bash
cd /root/fail2ban
./install.sh
```

**What it does:**
- Copies source to `/usr/share/fail2ban/` (permanent location)
- Installs fail2ban packages (dnf/yum)
- Deploys config to `/etc/fail2ban/`
- Installs libmaxminddb for GeoIP
- Sets up IP2Location LITE DB1 for country lookup
- Installs logrotate config for fail2ban.log
- Enables and starts fail2ban
- **Installs WHM plugin** if cPanel is detected
- You may remove `/root/fail2ban` after install

## Config Deploy Only (fail2ban already installed)

```bash
/usr/share/fail2ban/update.sh
```

Copies filters, jails, actions, scripts, and logrotate config from `/usr/share/fail2ban/` to `/etc/fail2ban/` and restarts fail2ban.

## Uninstall

```bash
# Remove only custom config (keep fail2ban service)
/usr/share/fail2ban/uninstall.sh

# Full removal: config, packages, WHM plugin, /usr/share/fail2ban/
/usr/share/fail2ban/uninstall.sh --purge
```
