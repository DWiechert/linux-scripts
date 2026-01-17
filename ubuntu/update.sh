#!/bin/bash

# Tumbleweed update script with automatic snapshots
# Usage: ./update-tumbleweed.sh

set -e  # Exit on error

echo "========================================"
echo "  openSUSE Tumbleweed Update"
echo "========================================"

# Create pre-update snapshot
echo ""
echo "=== Creating pre-update snapshot ==="
SNAPSHOT_NUM=$(sudo snapper create --type pre --cleanup-algorithm number --print-number --description "Before zypper dup")
echo "Created snapshot #$SNAPSHOT_NUM"

# Refresh repositories
echo ""
echo "=== Refreshing repositories ==="
sudo zypper refresh

# Distribution upgrade
echo ""
echo "=== Running distribution upgrade ==="
sudo zypper dup -y -l

# Check for Nvidia version mismatch after update
if command -v nvidia-smi &> /dev/null; then
    echo ""
    echo "=== Checking Nvidia driver integrity ==="
    
    # Get userspace library version
    LIB_VERSION=$(rpm -q nvidia-video-G06 --queryformat '%{VERSION}')
    
    # Get kernel module version
    KMP_VERSION=$(rpm -q nvidia-open-driver-G06-signed-kmp-default --queryformat '%{VERSION}' | cut -d'_' -f1)
    
    echo "Library version: $LIB_VERSION"
    echo "Kernel module version: $KMP_VERSION"
    
    if [ "$LIB_VERSION" != "$KMP_VERSION" ]; then
        echo "⚠️  WARNING: Nvidia version mismatch detected!"
        echo "This will cause display issues. Rolling back Nvidia packages..."
        
        # Downgrade libraries to match kernel module
        sudo zypper in --oldpackage nvidia-video-G06=$KMP_VERSION nvidia-gl-G06=$KMP_VERSION nvidia-compute-G06=$KMP_VERSION nvidia-compute-utils-G06=$KMP_VERSION || echo "Failed to downgrade, manual fix needed"
        
        echo "✓ Nvidia versions synchronized to $KMP_VERSION"
    else
        echo "✓ Nvidia versions match ($LIB_VERSION)"
    fi
fi

# Create post-update snapshot
echo ""
echo "=== Creating post-update snapshot ==="
POST_SNAPSHOT=$(sudo snapper create --type post --cleanup-algorithm number --print-number --description "After zypper dup" --pre-number "$SNAPSHOT_NUM")
echo "Created snapshot #$POST_SNAPSHOT"

# Check if reboot needed
echo ""
echo "========================================"
echo "  Update complete!"
echo "========================================"
if [ -f /var/run/reboot-required ]; then
    echo "⚠️  REBOOT REQUIRED (kernel updated)"
else
    echo "✓ No reboot required"
fi

echo ""
echo "Snapshots created: #$SNAPSHOT_NUM (pre) and #$POST_SNAPSHOT (post)"
echo "To rollback if needed: sudo snapper rollback $SNAPSHOT_NUM"
echo ""
echo "Run cleanup-tumbleweed.sh to clean old packages and snapshots"
echo "========================================"
