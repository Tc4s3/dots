#!/bin/bash
 
#Mnemosyne dock check

SESSION_NAME="T1"  

if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "MN3M05YN3: C0NN3CT3D"
else
    echo "MN3M05YN3: D1SC0NN3CT3D"
fi

# Uptime as Days:Hours:Minutes

uptime_seconds=$(</proc/uptime awk '{print int($1)}')
days=$((uptime_seconds/86400))
hours=$(( (uptime_seconds%86400)/3600 ))
minutes=$(( (uptime_seconds%3600)/60 ))
printf "󰄿 %dD:%02dH:%02dM\n" "$days" "$hours" "$minutes"

# System boot time in Date | HH:MM format

boot_time=$(uptime -s)
boot_date=$(date -d "$boot_time" '+%Y-%m-%d')
boot_clock=$(date -d "$boot_time" '+%H:%M')
echo "󰄽 $boot_date | $boot_clock"
