#!/bin/bash

# Tumbleweed update script - Option 2: Skip Nvidia packages when versions mismatch
# Usage: ./update-tumbleweed-option2.sh

set -e  # Exit on error

echo "========================================"
echo "  openSUSE Tumbleweed Update"
echo "  (Skip Nvidia on Version Mismatch)"
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

# Check Nvidia version compatibility BEFORE updating
SKIP_NVIDIA=false
if command -v nvidia-smi &> /dev/null; then
    echo ""
    echo "=== Checking Nvidia version compatibility ==="
    
    # Get current versions
    CURRENT_LIB=$(rpm -q nvidia-video-G06 --queryformat '%{VERSION}')
    CURRENT_KMP=$(rpm -q nvidia-open-driver-G06-signed-kmp-default --queryformat '%{VERSION}' | cut -d'_' -f1)
    
    echo "Current library version: $CURRENT_LIB"
    echo "Current kernel module version: $CURRENT_KMP"
    
    # Check what versions would be installed after update
    AVAILABLE_LIB=$(zypper info nvidia-video-G06 | grep "^Version" | awk '{print $3}')
    AVAILABLE_KMP=$(zypper info nvidia-open-driver-G06-signed-kmp-default | grep "^Version" | awk '{print $3}' | cut -d'_' -f1)
    
    echo "Available library version: $AVAILABLE_LIB"
    echo "Available kernel module version: $AVAILABLE_KMP"
    
    if [ -n "$AVAILABLE_LIB" ] && [ -n "$AVAILABLE_KMP" ] && [ "$AVAILABLE_LIB" != "$AVAILABLE_KMP" ]; then
        echo ""
        echo "⚠️  Nvidia version mismatch detected in repositories"
        echo "Will exclude Nvidia packages from this update"
        SKIP_NVIDIA=true
    else
        echo "✓ Nvidia versions are compatible"
    fi
fi

# Distribution upgrade with conditional Nvidia exclusion
echo ""
echo "=== Running distribution upgrade ==="
if [ "$SKIP_NVIDIA" = true ]; then
    echo "Excluding Nvidia packages from update..."
    sudo zypper dup -y -l \
        --no-recommends \
        $(zypper se -i nvidia | grep "^i" | awk '{print "--from-repo ! " $NF}' | tr '\n' ' ')
    
    echo ""
    echo "✓ System updated (Nvidia packages skipped)"
    echo "Your Nvidia drivers remain at: $CURRENT_LIB"
else
    sudo zypper dup -y -l
    echo ""
    echo "✓ System updated (including Nvidia)"
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

if [ "$SKIP_NVIDIA" = true ]; then
    echo ""
    echo "ℹ️  Note: Nvidia packages were not updated due to version mismatch"
    echo "Run this script again in a few days when versions are synchronized"
fi

echo ""
echo "Snapshots created: #$SNAPSHOT_NUM (pre) and #$POST_SNAPSHOT (post)"
echo "To rollback if needed: sudo snapper rollback $SNAPSHOT_NUM"
echo ""
echo "Run cleanup-tumbleweed.sh to clean old packages and snapshots"
echo "========================================"
