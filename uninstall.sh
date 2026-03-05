#!/bin/bash
#
# Fail2Ban WordPress wp-login - Uninstall script
# Removes deployed config and optionally uninstalls fail2ban
# Must be run as root
#

set -e

F2B_FILTER="/etc/fail2ban/filter.d/wordpress-wp-login.conf"
F2B_JAIL="/etc/fail2ban/jail.d/wordpress-wp-login.conf"
PURGE=false

# Parse args
for arg in "$@"; do
   case $arg in
      --purge)
         PURGE=true
         shift
         ;;
   esac
done

# Check root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" >&2
   exit 1
fi

echo "=== Fail2Ban WordPress wp-login - Uninstall ==="
echo

# 1. Stop fail2ban (needed to remove config cleanly)
echo "[1/4] Stopping fail2ban..."
if systemctl is-active --quiet fail2ban 2>/dev/null; then
   systemctl stop fail2ban
   echo "      fail2ban stopped."
else
   echo "      fail2ban was not running."
fi

# 2. Remove deployed config
echo "[2/4] Removing config..."
removed=0
if [[ -f "$F2B_FILTER" ]]; then
   rm -f "$F2B_FILTER"
   echo "      Removed: $F2B_FILTER"
   removed=1
fi
if [[ -f "$F2B_JAIL" ]]; then
   rm -f "$F2B_JAIL"
   echo "      Removed: $F2B_JAIL"
   removed=1
fi
if [[ $removed -eq 0 ]]; then
   echo "      No WordPress wp-login config found."
fi

# 3. Restart or disable fail2ban
if [[ "$PURGE" == true ]]; then
   echo "[3/4] Disabling fail2ban service..."
   systemctl disable fail2ban 2>/dev/null || true
   echo "      fail2ban disabled."
   echo
   echo "[4/4] Uninstalling fail2ban packages..."
   if rpm -q fail2ban-server &>/dev/null; then
      if command -v dnf &>/dev/null; then
         dnf remove -y fail2ban fail2ban-systemd fail2ban-firewalld fail2ban-sendmail 2>/dev/null || true
      elif command -v yum &>/dev/null; then
         yum remove -y fail2ban fail2ban-systemd fail2ban-firewalld fail2ban-sendmail 2>/dev/null || true
      fi
      echo "      fail2ban packages removed."
   else
      echo "      fail2ban was not installed."
   fi
else
   echo "[3/4] Restarting fail2ban..."
   if rpm -q fail2ban-server &>/dev/null; then
      systemctl start fail2ban
      sleep 2
      echo "      fail2ban restarted (WordPress jail removed)."
   fi
   echo "[4/4] (Skipped - use --purge to also uninstall fail2ban packages)"
fi

echo
echo "=== Uninstall complete ==="
