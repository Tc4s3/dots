#!/bin/bash

# ANSI color code printer
ansi_color() {
    local code="$1"
    printf "\033[38;5;%sm%3s\033[0m" "$code" "$code"
}

# Convert RGB to hex
rgb_to_hex() {
    printf "#%02x%02x%02x" "$1" "$2" "$3"
}

# Calculate the closest ANSI 256 color code from RGB
rgb_to_ansi256() {
    local r="$1" g="$2" b="$3"

    # Handle grayscale
    if [[ "$r" -eq "$g" && "$g" -eq "$b" ]]; then
        if [[ "$r" -lt 8 ]]; then
            echo 16
            return
        elif [[ "$r" -gt 248 ]]; then
            echo 231
            return
        else
            local gray=$((232 + (r - 8) * 23 / 247))
            echo "$gray"
            return
        fi
    fi

    # 6x6x6 color cube
    local r6=$((r * 5 / 255))
    local g6=$((g * 5 / 255))
    local b6=$((b * 5 / 255))
    local ansi=$((16 + 36 * r6 + 6 * g6 + b6))
    echo "$ansi"
}

# Parse a GPL file and extract RGB values
parse_gpl() {
    local file="$1"
    local line name r g b

    while IFS= read -r line; do
        line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        if [[ -z "$line" || "$line" =~ ^# ]]; then
            continue
        fi

        # Match lines with R G B [Name]
        if [[ "$line" =~ ^([0-9]+)[[:space:]]+([0-9]+)[[:space:]]+([0-9]+)([[:space:]]+(.*))?$ ]]; then
            r="${BASH_REMATCH[1]}"
            g="${BASH_REMATCH[2]}"
            b="${BASH_REMATCH[3]}"
            name="${BASH_REMATCH[5]}"
            echo "$r $g $b $name"
        fi
    done < "$file"
}

# Generate the formatted output line
format_output_line() {
    local r="$1" g="$2" b="$3" name="$4"
    local ansi_code=$(rgb_to_ansi256 "$r" "$g" "$b")
    local hex_code=$(rgb_to_hex "$r" "$g" "$b")
    printf "ANSI: %s | HEX: %s | RGB: %3d %3d %3d | %s\n" \
           "$(ansi_color "$ansi_code")" "$hex_code" "$r" "$g" "$b" "$name"
}

# Remove duplicate ANSI codes (keep first occurrence)
remove_duplicates() {
    declare -A seen_ansi
    while read -r r g b name; do
        ansi_code=$(rgb_to_ansi256 "$r" "$g" "$b")
        if [[ -z "${seen_ansi[$ansi_code]}" ]]; then
            seen_ansi[$ansi_code]=1
            echo "$r $g $b $name"
        fi
    done
}

# Display colored ANSI codes
display_colors() {
    echo -e "\nMatched ANSI Colors (Duplicates Removed):"
    while read -r r g b name; do
        format_output_line "$r" "$g" "$b" "$name"
    done
}

# Save ANSI codes to a file (identical to terminal output)
save_ansi_codes() {
    local outfile="$1"
    echo "Matched ANSI Colors (Duplicates Removed):" > "$outfile"
    while read -r r g b name; do
        # Use sed to strip ANSI codes for the text file
        format_output_line "$r" "$g" "$b" "$name" | sed -r "s/\x1B\[[0-9;]*[mK]//g" >> "$outfile"
    done
    echo -e "\nOutput saved to: $(realpath "$outfile")"
}

# Main script
main() {
    echo "GPL to ANSI 256 + HEX Color Converter (No Duplicates)"

    # Get GPL file path
    while true; do
        read -p $'\nEnter path to .gpl file (relative or absolute): ' gpl_file
        if [[ -z "$gpl_file" ]]; then
            echo "Please enter a file path."
            continue
        fi
        if [[ ! -f "$gpl_file" ]]; then
            echo "File not found. Please try again."
            continue
        fi
        if [[ ! "$gpl_file" =~ \.gpl$ ]]; then
            echo "Warning: File does not have a .gpl extension. Continue anyway? [y/N]"
            read -r confirm
            [[ "$confirm" =~ ^[Yy]$ ]] || continue
        fi
        break
    done

    # Parse and remove duplicates
    parsed_colors=$(parse_gpl "$gpl_file" | remove_duplicates)
    if [[ -z "$parsed_colors" ]]; then
        echo "No colors found in the file or error parsing."
        return 1
    fi

    echo "$parsed_colors" | display_colors

    # Get output file path
    while true; do
        read -p $'\nEnter path to save output (relative or absolute, .txt): ' out_file
        if [[ -z "$out_file" ]]; then
            echo "Please enter a file path."
            continue
        fi
        # Ensure .txt extension
        if [[ ! "$out_file" =~ \.txt$ ]]; then
            out_file="${out_file}.txt"
        fi
        # Check if directory exists
        out_dir=$(dirname "$out_file")
        if [[ -n "$out_dir" && ! -d "$out_dir" ]]; then
            echo "Directory '$out_dir' does not exist. Please try again."
            continue
        fi
        break
    done

    # Save output (identical to terminal, minus ANSI codes)
    echo "$parsed_colors" | save_ansi_codes "$out_file"
}

main "$@"