#!/bin/bash

# Configuration
LOW_BATTERY_THRESHOLD=25
CRITICAL_BATTERY_THRESHOLD=15
CHECK_INTERVAL=60  # seconds

# Function to get battery info
get_battery_info() {
    # Try multiple methods to get battery info
    local capacity status
    
    # Method 1: sysfs (most reliable)
    local battery_path="/sys/class/power_supply"
    for bat in BAT0 BAT1; do
        if [ -d "$battery_path/$bat" ]; then
            capacity=$(cat "$battery_path/$bat/capacity" 2>/dev/null)
            status=$(cat "$battery_path/$bat/status" 2>/dev/null)
            [ -n "$capacity" ] && break
        fi
    done
    
    # Method 2: acpi (fallback)
    if [ -z "$capacity" ] && command -v acpi >/dev/null; then
        local acpi_info=$(acpi -b 2>/dev/null)
        capacity=$(echo "$acpi_info" | grep -oP '\d+(?=%)' | head -1)
        status=$(echo "$acpi_info" | grep -oP 'Discharging|Charging|Full' | head -1)
    fi
    
    echo "${capacity:-0} ${status:-Unknown}"
}

# Function to send notification
send_notification() {
    local level=$1
    local message=$2
    local urgency=$3
    local timeout=$4
    
    # Use dunstify if available, else fallback to notify-send
    if command -v dunstify >/dev/null; then
        dunstify -u "$urgency" -t "$timeout" -h "int:value:$level" \
            "Battery Warning" "$message"
    else
        notify-send -u "$urgency" -t "$timeout" \
            "Battery Warning" "$message"
    fi
}

# Main monitoring loop
echo "Starting battery monitor..."
while true; do
    read capacity status <<< $(get_battery_info)
    
    # Only act if we got valid battery info
    if [[ "$capacity" =~ ^[0-9]+$ ]] && [ -n "$status" ]; then
        if [ "$status" = "Discharging" ]; then
            if [ "$capacity" -le "$CRITICAL_BATTERY_THRESHOLD" ]; then
                send_notification "$capacity" "CRITICAL! Battery at $capacity%. Plug in immediately!" "critical" 0
            elif [ "$capacity" -le "$LOW_BATTERY_THRESHOLD" ]; then
                send_notification "$capacity" "Low battery: $capacity%. Connect charger soon." "normal" 10000
            fi
        fi
    else
        echo "Could not get battery information"
    fi
    
    sleep $CHECK_INTERVAL
done
