#!/bin/bash

# Tumbleweed cleanup script
# Usage: ./cleanup-tumbleweed.sh

set -e  # Exit on error

echo "========================================"
echo "  openSUSE Tumbleweed Cleanup"
echo "========================================"

# Create pre-cleanup snapshot
echo ""
echo "=== Creating pre-cleanup snapshot ==="
SNAPSHOT_NUM=$(sudo snapper create --type single --cleanup-algorithm number --print-number --description "Before cleanup")
echo "Created snapshot #$SNAPSHOT_NUM"

# Clean package cache
echo ""
echo "=== Cleaning package cache ==="
sudo zypper clean --all
echo "✓ Package cache cleaned"

# Check for orphaned packages
echo ""
echo "=== Checking for orphaned packages ==="
ORPHANED=$(sudo zypper packages --orphaned | grep "^i" || true)
if [ -n "$ORPHANED" ]; then
    echo "Found orphaned packages:"
    echo "$ORPHANED"
    echo ""
    read -p "Remove orphaned packages? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo zypper remove $(sudo zypper packages --orphaned | awk '/^i/ {print $5}')
        echo "✓ Orphaned packages removed"
    else
        echo "Skipped orphaned package removal"
    fi
else
    echo "✓ No orphaned packages found"
fi

# Clean old snapshots
echo ""
echo "=== Current snapshots ==="
SNAPSHOT_COUNT=$(sudo snapper list | tail -n +3 | wc -l)
echo "Total snapshots: $SNAPSHOT_COUNT"
sudo snapper list

echo ""
echo "=== Cleaning old snapshots ==="
echo "Current retention limits:"
sudo snapper get-config | grep -E "NUMBER_LIMIT|TIMELINE_LIMIT"
echo ""
read -p "Run automatic cleanup? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo snapper cleanup number
    echo "✓ Old snapshots cleaned"
    NEW_COUNT=$(sudo snapper list | tail -n +3 | wc -l)
    echo "Snapshots remaining: $NEW_COUNT"
else
    echo "Skipped snapshot cleanup"
fi

# Show disk usage
echo ""
echo "=== Disk usage for Btrfs snapshots ==="
sudo btrfs filesystem usage / 2>/dev/null || df -h /

echo ""
echo "========================================"
echo "  Cleanup complete!"
echo "========================================"
echo "Snapshot created: #$SNAPSHOT_NUM"
echo "To rollback if needed: sudo snapper rollback $SNAPSHOT_NUM"
echo "========================================"
