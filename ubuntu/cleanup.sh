#!/bin/bash

# Ubuntu Server automated cleanup script
# Usage: ./cleanup-ubuntu-auto.sh
# Safe for cron: 0 3 * * 0 /home/user/cleanup-ubuntu-auto.sh >> /var/log/auto-cleanup.log 2>&1

set -x  # Show commands (for logging)

echo "========================================"
echo "  Ubuntu Server Automated Cleanup"
echo "  $(date)"
echo "========================================"

# Clean apt cache
echo "=== Cleaning apt cache ==="
sudo apt clean
sudo apt autoclean
sudo apt autoremove -y

# Remove old kernels (keep current + 1 previous)
echo "=== Removing old kernels ==="
CURRENT_KERNEL=$(uname -r | sed 's/-generic//')
dpkg -l | grep -E 'linux-image-[0-9]' | awk '{print $2}' | grep -v "$CURRENT_KERNEL" | sort -V | head -n -1 | xargs -r sudo apt remove --purge -y || true
sudo apt autoremove -y

# Clean journal logs (keep last 14 days)
echo "=== Cleaning system logs ==="
sudo journalctl --vacuum-time=14d

# Docker cleanup if installed
if command -v docker &> /dev/null; then
    echo "=== Docker cleanup ==="
    echo "Before cleanup:"
    sudo docker system df || true
    
    # Remove stopped containers
    sudo docker container prune -f
    
    # Remove dangling images only (safer than --all)
    sudo docker image prune -f
    
    # Remove unused volumes
    sudo docker volume prune -f
    
    # Remove unused networks
    sudo docker network prune -f
    
    # Optional: Remove ALL unused images (uncomment if you want aggressive cleanup like your script)
    # sudo docker image prune -a -f
    # sudo docker system prune -a -f
    
    echo "After cleanup:"
    sudo docker system df || true
fi

# Clean Timeshift snapshots older than 30 days
if command -v timeshift &> /dev/null; then
    echo "=== Cleaning old Timeshift snapshots ==="
    sudo timeshift --delete-all --older-than 30 --scripted || true
fi

# Show disk usage
echo ""
echo "=== Disk usage ==="
df -h /

echo ""
echo "========================================"
echo "  Cleanup complete!"
echo "  $(date)"
echo "========================================"
