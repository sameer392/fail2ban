#!/bin/bash
# IP2Location LITE DB1 (Country) setup for fail2ban
# Run as root. Uses token for automated downloads; fallback to direct LITE URL.
# LITE database updates monthly (first day). Add cron for weekly updates.

set -e
[ "$EUID" -ne 0 ] && { echo "Run as root"; exit 1; }

TOKEN="${IP2LOCATION_TOKEN:-j4lX5sxtvlmBvdki8ITEPt9zmJUraz7xHkFx64piNGMyH6ubyA1EdhAubhBtfrH3}"
GEOIP_DIR="/etc/fail2ban/GeoIP"
DB_DIR="${IP2LOCATION_DB_DIR:-$GEOIP_DIR}"
SCRIPT_DIR="$(dirname "$0")"

echo "=== IP2Location LITE DB1 Setup for fail2ban ==="

# Install libmaxminddb and mmdblookup
if ! command -v mmdblookup &>/dev/null; then
    echo "Installing libmaxminddb..."
    dnf install -y libmaxminddb libmaxminddb-utils 2>/dev/null || yum install -y libmaxminddb libmaxminddb-utils 2>/dev/null || {
        echo "Install manually: dnf install libmaxminddb libmaxminddb-utils"
        exit 1
    }
fi

mkdir -p "$GEOIP_DIR"

# Store token for update cron (avoid hardcoding in cron script)
if [ ! -f "$GEOIP_DIR/ip2location.conf" ]; then
    echo "IP2LOCATION_TOKEN=$TOKEN" > "$GEOIP_DIR/ip2location.conf"
    echo "IP2LOCATION_DB_DIR=$DB_DIR" >> "$GEOIP_DIR/ip2location.conf"
    chmod 600 "$GEOIP_DIR/ip2location.conf"
fi

echo "Downloading IP2Location LITE DB1 (MMDB)..."

ZIP="/tmp/IP2LOCATION-LITE-DB1.MMDB.ZIP"
is_valid_zip() {
    [ -s "$1" ] && [ "$(head -c 2 "$1" | od -An -tx1 | tr -d ' \n')" = "504b" ]
}
download_and_validate() {
    local url="$1"
    rm -f "$ZIP"
    curl -sLf -o "$ZIP" "$url" 2>/dev/null && is_valid_zip "$ZIP"
}

# Prefer direct LITE mirror (no token); fallback to token-based
if ! download_and_validate "https://download.ip2location.com/lite/IP2LOCATION-LITE-DB1.MMDB.ZIP"; then
    echo "Direct mirror failed, trying token-based download..."
    for FILE_CODE in DB1LITEMMDB DB1LITE.MMDB; do
        if download_and_validate "https://www.ip2location.com/download?token=${TOKEN}&file=${FILE_CODE}"; then
            break
        fi
    done
fi

if ! is_valid_zip "$ZIP"; then
    if [ -s "$ZIP" ] && head -c 80 "$ZIP" | grep -qi "ONLY BE DOWNLOADED"; then
        echo "IP2Location rate limit: 5 downloads per 24h per IP. Wait or use a different IP."
    else
        echo "Failed to download valid database. Check network or set IP2LOCATION_TOKEN."
    fi
    rm -f "$ZIP"
    exit 1
fi

# Extract and install
TMPDIR=$(mktemp -d)
unzip -q -o "$ZIP" -d "$TMPDIR"
rm -f "$ZIP"

MMDB=$(find "$TMPDIR" -iname "*.mmdb" -type f | head -1)
if [ -n "$MMDB" ]; then
    install -m 644 "$MMDB" "$DB_DIR/IP2LOCATION-LITE-DB1.mmdb"
    echo "Installed to $DB_DIR/IP2LOCATION-LITE-DB1.mmdb"
else
    echo "No .mmdb file found in archive"
    rm -rf "$TMPDIR"
    exit 1
fi
rm -rf "$TMPDIR"

echo ""
echo "Setup complete. csf-ban.sh will use IP2Location for country lookup."
echo "Add weekly cron for auto-updates:"
echo "  0 3 * * 3 root [ -f /etc/fail2ban/GeoIP/ip2location.conf ] && . /etc/fail2ban/GeoIP/ip2location.conf && /etc/fail2ban/scripts/update-ip2location.sh"
