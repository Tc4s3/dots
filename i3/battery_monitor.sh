#!/bin/bash

# Battery monitoring script for i3wm
# Place in ~/.config/i3/ or ~/ and add to i3 config: exec --no-startup-id ~/battery_monitor.sh

# Check every 60 seconds
CHECK_INTERVAL=60

# Thresholds
LOW_BATTERY_THRESHOLD=25
CRITICAL_BATTERY_THRESHOLD=20

# Lock/suspend command
SUSPEND_CMD="systemctl suspend && i3lock -i /home/operator/Pictures/namibia2kpxlD.jpg -t"

# Function to get battery percentage
get_battery_percentage() {
    local battery_path="/sys/class/power_supply/BAT0/capacity"
    
    if [ -f "$battery_path" ]; then
        cat "$battery_path"
    else
        echo "100" # Default if battery not found
    fi
}

# Function to show notification
show_notification() {
    local message="$1"
    # Use Konsole floating window
    konsole --name floating_battery_alert --geometry 20x10 -e bash -c "echo -e \"$message\nPress Enter to close\"; read" &
}

# Main monitoring loop
while true; do
    battery_level=$(get_battery_percentage)
    
    if [ "$battery_level" -le "$CRITICAL_BATTERY_THRESHOLD" ]; then
        # Critical battery level - suspend system
        show_notification "CRITICAL BATTERY: ${battery_level}%\nSystem will suspend in 5 seconds!"
        sleep 5
        eval "$SUSPEND_CMD"
        break # Exit script after suspend
        
    elif [ "$battery_level" -le "$LOW_BATTERY_THRESHOLD" ]; then
        # Low battery warning
        show_notification "LOW BATTERY WARNING: ${battery_level}%\nPlease connect to power soon."
    fi
    
    sleep "$CHECK_INTERVAL"
done
