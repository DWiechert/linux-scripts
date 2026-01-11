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
    echo "⚠  REBOOT REQUIRED (kernel updated)"
else
    echo "✓ No reboot required"
fi

echo ""
echo "Snapshots created: #$SNAPSHOT_NUM (pre) and #$POST_SNAPSHOT (post)"
echo "To rollback if needed: sudo snapper rollback $SNAPSHOT_NUM"
echo ""
echo "Run cleanup.sh to clean old packages and snapshots"
echo "========================================"
