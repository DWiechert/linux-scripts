#!/bin/bash

# Ubuntu Server automated update script
# Usage: ./update-ubuntu-auto.sh
# Safe for cron: 0 2 * * 0 /home/user/update-ubuntu-auto.sh >> /var/log/auto-update.log 2>&1

set -e  # Exit on error
set -x  # Show commands (for logging)

echo "========================================"
echo "  Ubuntu Server Automated Update"
echo "  $(date)"
echo "========================================"

# Create package list backup
echo "=== Creating package list backup ==="
BACKUP_DIR="$HOME/package-backups"
mkdir -p "$BACKUP_DIR"
BACKUP_FILE="$BACKUP_DIR/packages-$(date +%Y%m%d-%H%M%S).txt"
dpkg --get-selections > "$BACKUP_FILE"
echo "✓ Package list saved to: $BACKUP_FILE"

# Keep only last 10 backups
ls -t "$BACKUP_DIR"/packages-*.txt | tail -n +11 | xargs -r rm
echo "✓ Old backups cleaned (keeping last 10)"

# Update package lists
echo "=== Updating package lists ==="
sudo apt update

# Upgrade packages
echo "=== Upgrading packages ==="
sudo apt upgrade -y

# Distribution upgrade
echo "=== Distribution upgrade ==="
sudo apt dist-upgrade -y

# Remove unused packages
echo "=== Removing unused packages ==="
sudo apt autoremove -y

# Check if reboot needed
echo ""
echo "========================================"
echo "  Update complete!"
echo "========================================"

if [ -f /var/run/reboot-required ]; then
    echo "⚠️  REBOOT REQUIRED"
    cat /var/run/reboot-required.pkgs 2>/dev/null || true
    
    # Optionally auto-reboot (uncomment if desired)
    # echo "Rebooting in 60 seconds..."
    # sleep 60
    # sudo reboot
else
    echo "✓ No reboot required"
fi

echo "Completed at: $(date)"
echo "========================================"
