#!/bin/bash

echo "jp2a Custom ASCII Art Generator"
echo "--------------------------------"

validate_chars() {
    local chars=$1 invalid_chars="'\`\\!$&|<>[]{}()*?;"
    for ((i=0; i<${#chars}; i++)); do
        [[ "$invalid_chars" == *"${chars:$i:1}"* ]] && {
            echo "Error: Invalid character '${chars:$i:1}'."
            return 1
        }
    done
    [[ -n "$chars" && ${#chars} -lt 2 ]] && {
        echo "Error: Need at least 2 characters."
        return 1
    }
    return 0
}

resolve_path() {
    [[ "$1" == /* ]] && echo "$1" || echo "$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
}

read -p "Enter image path (relative/absolute): " input_file
resolved_path=$(resolve_path "$input_file")
while [ ! -f "$resolved_path" ]; do
    echo "File not found: $resolved_path"
    read -p "Enter image path: " input_file
    resolved_path=$(resolve_path "$input_file")
done

read -p "Output size (e.g., 80x40 or 'full'): " size
[[ -z "$size" ]] && size_option="" || size_option="--size=$size"

read -p "Color depth (1-16, empty for default): " color_depth
if [[ -n "$color_depth" ]]; then
    [[ "$color_depth" =~ ^[0-9]+$ ]] && color_depth_option="--color-depth=$color_depth" || 
        echo "Using default color depth."
fi

chars=""
while true; do
    read -p $'Characters to use (empty for default)\nAvoid: !$&`\'\\|<>[]{}()*?;\nChars: ' chars
    [[ -z "$chars" ]] && { chars_option=""; echo "Using defaults."; break; }
    validate_chars "$chars" && { chars_option="--chars=\"$chars\""; break; }
    echo "Invalid chars, try again."
done

output_file="jp2a_output_$(date +%Y%m%d_%H%M%S).txt"
command="jp2a $size_option $color_depth_option $chars_option \"$resolved_path\""

echo -e "\nGenerating output to $output_file and displaying below:\n"
eval "$command" | tee "$output_file"
echo -e "\nOutput saved to: $output_file"
