#!/bin/bash

while true; do
    # Display available drives
    echo -e "\nAvailable drives and partitions:"
    lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT | grep -v "loop"
    echo ""

    # Ask user for the device (e.g., sdb1)
    read -p "Enter the partition you want to mount (e.g., sdb1) or 'exit' to quit: " PARTITION

    # Exit condition
    if [[ "$PARTITION" == "exit" ]]; then
        echo "Exiting..."
        break
    fi

    # Check if the partition exists
    if ! lsblk -o NAME | grep -wq "$PARTITION"; then
        echo "Error: Partition '/dev/$PARTITION' not found!"
        continue
    fi

    # Ask for mount point
    read -p "Enter the mount point (e.g., /mnt/usb): " MOUNT_POINT

    # Create mount point if it doesn't exist
    if [ ! -d "$MOUNT_POINT" ]; then
        sudo mkdir -p "$MOUNT_POINT"
    fi

    # Mount the partition
    echo "Mounting /dev/$PARTITION to $MOUNT_POINT..."
    sudo mount "/dev/$PARTITION" "$MOUNT_POINT"

    # Verify mount was successful
    if mountpoint -q "$MOUNT_POINT"; then
        echo "Successfully mounted /dev/$PARTITION at $MOUNT_POINT"
        df -h | grep "$PARTITION"
    else
        echo "Failed to mount /dev/$PARTITION!"
    fi

    # Ask to repeat or exit
    read -p "Do you want to mount another drive? (y/n): " REPEAT
    if [[ "$REPEAT" != "y" && "$REPEAT" != "Y" ]]; then
        echo "Exiting..."
        break
    fi
done