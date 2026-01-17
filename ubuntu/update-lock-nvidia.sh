#!/bin/bash

# Tumbleweed update script - Option 1: Find and lock to newest common Nvidia version
# Usage: ./update-tumbleweed-option1.sh

set -e  # Exit on error

echo "========================================"
echo "  openSUSE Tumbleweed Update"
echo "  (Lock to Common Nvidia Version)"
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
if command -v nvidia-smi &> /dev/null; then
    echo ""
    echo "=== Finding newest common Nvidia version ==="
    
    # Get all available versions for both packages
    LIB_VERSIONS=$(zypper se -s nvidia-video-G06 | grep "^i\|^v" | awk '{print $7}' | sort -V)
    KMP_VERSIONS=$(zypper se -s nvidia-open-driver-G06-signed-kmp-default | grep "^i\|^v" | awk '{print $7}' | cut -d'_' -f1 | sort -V)
    
    # Find newest common version
    COMMON_VERSION=""
    for lib_ver in $LIB_VERSIONS; do
        for kmp_ver in $KMP_VERSIONS; do
            if [ "$lib_ver" = "$kmp_ver" ]; then
                COMMON_VERSION="$lib_ver"
            fi
        done
    done
    
    if [ -n "$COMMON_VERSION" ]; then
        echo "✓ Found common version: $COMMON_VERSION"
        echo "Locking Nvidia packages to this version..."
        
        # Add version locks
        sudo zypper al nvidia-video-G06-$COMMON_VERSION
        sudo zypper al nvidia-gl-G06-$COMMON_VERSION
        sudo zypper al nvidia-compute-G06-$COMMON_VERSION
        sudo zypper al nvidia-compute-utils-G06-$COMMON_VERSION
        sudo zypper al nvidia-open-driver-G06-signed-kmp-default
        
        echo "✓ Nvidia packages locked to $COMMON_VERSION"
    else
        echo "⚠️  No common version found, proceeding without locks"
    fi
fi

# Distribution upgrade
echo ""
echo "=== Running distribution upgrade ==="
sudo zypper dup -y -l

# Remove version locks
if [ -n "$COMMON_VERSION" ]; then
    echo ""
    echo "=== Removing Nvidia version locks ==="
    sudo zypper rl nvidia-video-G06-$COMMON_VERSION || true
    sudo zypper rl nvidia-gl-G06-$COMMON_VERSION || true
    sudo zypper rl nvidia-compute-G06-$COMMON_VERSION || true
    sudo zypper rl nvidia-compute-utils-G06-$COMMON_VERSION || true
    sudo zypper rl nvidia-open-driver-G06-signed-kmp-default || true
    echo "✓ Locks removed"
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
