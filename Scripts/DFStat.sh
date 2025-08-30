#!/bin/bash

DATA_FORTS_DIR="$HOME/DataForts"
mount_points=("ALPHA-I" "ALPHA-II" "BETA-I" "BETA-II")
unmounted_dirs=()
total_dirs=${#mount_points[@]}
mounted_dirs=0

# Check if DataForts directory exists
if [ ! -d "$DATA_FORTS_DIR" ]; then
    echo "0FFL1N3"
    exit 1
fi

# Check mount status for each predefined directory
for dir in "${mount_points[@]}"; do
    full_path="$DATA_FORTS_DIR/$dir"
    if [ -d "$full_path" ]; then
        if mountpoint -q "$full_path"; then
            ((mounted_dirs++))
        else
            unmounted_dirs+=("$dir")
        fi
    else
        unmounted_dirs+=("$dir")
    fi
done

# Output result - Modified to show ONLINE if any directory is mounted
if [ $total_dirs -eq 0 ]; then
    echo "DF: 0FFL1N3"
elif [ $mounted_dirs -gt 0 ]; then
    echo "DF: 0NL1N3"
elif [ ${#unmounted_dirs[@]} -eq $total_dirs ]; then
    echo "DF: 0FFL1N3"
else
    echo "DF: M1551NG"
    for dir in "${unmounted_dirs[@]}"; do
        echo "$dir"
    done
fi
