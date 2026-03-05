#!/bin/bash
# Uninstall Fail2Ban Manager WHM plugin
# Run as root.

set -e
[ "$EUID" -ne 0 ] && { echo "Run as root"; exit 1; }

echo "=== Uninstalling Fail2Ban Manager WHM plugin ==="

# Unregister from AppConfig (removes /var/cpanel/apps/fail2ban_manager.conf)
/usr/local/cpanel/bin/unregister_appconfig fail2ban_manager 2>/dev/null || true
rm -f /var/cpanel/apps/fail2ban_manager.conf 2>/dev/null || true

# Remove plugin files (must match install-whm-plugin.sh locations)
rm -f /usr/local/cpanel/whostmgr/docroot/addon_plugins/fail2ban_manager.png
rm -rf /usr/local/cpanel/whostmgr/docroot/cgi/fail2ban_manager

echo ""
echo "Restarting cPanel..."
if systemctl restart cpanel 2>/dev/null; then
   echo "cPanel restarted."
elif [ -x /usr/local/cpanel/scripts/restartsrv_cpsrvd ]; then
   /usr/local/cpanel/scripts/restartsrv_cpsrvd
   echo "cPanel restarted."
else
   echo "Could not restart cPanel automatically. Run: systemctl restart cpanel"
fi
echo ""
echo "Plugin uninstalled."
