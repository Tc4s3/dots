#!/bin/bash

read -p "Enter path to .gpl file: " gpl_file

while read -r line; do
    if [[ $line =~ ^[0-9] ]]; then
        rgb=$(echo "$line" | awk '{print $1","$2","$3}')
        hex=$(echo "$line" | awk '{printf "#%02x%02x%02x\n", $1, $2, $3}')
        printf "\e[48;2;%sm   \e[0m %s\n" "$rgb" "$hex"
    fi
done < "$gpl_file"