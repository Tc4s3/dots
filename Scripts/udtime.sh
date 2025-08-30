#!/bin/bash 

# Uptime as Days:Hours:Minutes

uptime_seconds=$(</proc/uptime awk '{print int($1)}')
days=$((uptime_seconds/86400))
hours=$(( (uptime_seconds%86400)/3600 ))
minutes=$(( (uptime_seconds%3600)/60 ))
printf "󰄿 %dD:%02dH:%02dM\n" "$days" "$hours" "$minutes"

