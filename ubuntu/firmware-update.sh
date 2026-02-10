#!/bin/bash

# Ubuntu firmware update script
# Usage: ./firmware-update.sh
# Run this manually when notified of available firmware updates

set -e  # Exit on error

echo "========================================"
echo "  Firmware Update"
echo "  $(date)"
echo "========================================"

# Check if fwupdmgr is installed
if ! command -v fwupdmgr &> /dev/null; then
    echo "❌ fwupdmgr not installed"
    echo "Install with: sudo apt install fwupd"
    exit 1
fi

# Create package list backup before firmware update
echo "=== Creating package list backup ==="
BACKUP_DIR="$HOME/package-backups"
mkdir -p "$BACKUP_DIR"
BACKUP_FILE="$BACKUP_DIR/packages-firmware-$(date +%Y%m%d-%H%M%S).txt"
dpkg --get-selections > "$BACKUP_FILE"
echo "✓ Package list saved to: $BACKUP_FILE"

# Refresh firmware metadata
echo ""
echo "=== Refreshing firmware metadata ==="
sudo fwupdmgr refresh --force

# Check for available updates
echo ""
echo "=== Checking for firmware updates ==="
if sudo fwupdmgr get-updates; then
    echo ""
    echo "========================================"
    echo "Firmware updates available!"
    echo "========================================"
    echo ""
    echo "⚠️  WARNING: Firmware updates can be risky"
    echo "- Do NOT interrupt the update process"
    echo "- Ensure stable power supply"
    echo "- System may reboot during update"
    echo ""
    read -p "Proceed with firmware update? (yes/NO): " -r
    
    if [[ $REPLY == "yes" ]]; then
        echo ""
        echo "=== Installing firmware updates ==="
        sudo fwupdmgr update
        
        echo ""
        echo "========================================"
        echo "  Firmware update complete!"
        echo "========================================"
        
        # Check if reboot needed
        if sudo fwupdmgr get-updates 2>&1 | grep -q "reboot"; then
            echo "⚠️  REBOOT REQUIRED"
            echo ""
            read -p "Reboot now? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                sudo reboot
            else
                echo "Remember to reboot when convenient"
            fi
        fi
    else
        echo "Firmware update cancelled"
        exit 0
    fi
else
    echo ""
    echo "✓ No firmware updates available"
fi

echo ""
echo "Completed at: $(date)"
echo "========================================"
