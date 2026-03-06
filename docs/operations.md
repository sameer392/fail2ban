# Operations

## Management Commands

```bash
# Service status
fail2ban-client status

# Per-jail status
fail2ban-client status wordpress-wp-login
fail2ban-client status apache-high-volume

# List banned IPs
fail2ban-client get wordpress-wp-login banip

# Unban an IP
fail2ban-client set wordpress-wp-login unbanip <IP_ADDRESS>

# Monitor log
tail -f /var/log/fail2ban.log

# Verify domlog path
ls /usr/local/apache/domlogs/*/* | head -5

# Status script
/usr/share/fail2ban/status.sh
```

---

## Shell Scripts Reference

| Script | Purpose |
|--------|---------|
| install.sh | Full install: copy to /usr/share/fail2ban, deploy, IP2Location, logrotate, enable, WHM plugin |
| update.sh | Deploy config to /etc/fail2ban (backs up first), restart fail2ban |
| restore-backup.sh | Restore from backup (default: latest). Usage: `restore-backup.sh [BACKUP_DIR]` |
| uninstall.sh | Remove config; --purge = also packages, WHM plugin, /etc and /usr/share |
| status.sh | Show fail2ban service and jail status |
| update-whitelist.sh | Regenerate filter ignoreregex from whitelist-ips.conf |

All scripts must be run as root.

---

## Logging and Rotation

| Item | Details |
|------|---------|
| **Log file** | `/var/log/fail2ban.log` |
| **Logrotate** | `/etc/logrotate.d/fail2ban` – rotate at 50MB or weekly, keep 4 compressed archives |
| **Flush** | Uses `fail2ban-client flushlogs` so no restart needed |
| **Immediate rotate** | `logrotate --force /etc/logrotate.d/fail2ban` |
| **Loglevel** | `fail2ban.d/loglevel-verbose.conf` – set INFO for more detail, WARNING for less. Remove file to use fail2ban default. |

### Backup & Restore

`update.sh` creates a timestamped backup in `/etc/fail2ban/backups/YYYYMMDD-HHMMSS/` before each deploy (keeps last 10). To restore: `restore-backup.sh` (latest) or `restore-backup.sh /etc/fail2ban/backups/YYYYMMDD-HHMMSS`.

---

## Applicability

This configuration protects **all** sites on the server. The log path `/usr/local/apache/domlogs/*/*` covers all cPanel domain logs (primary and addon domains).
