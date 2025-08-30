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

# Calculate Euclidean distance between two RGB colors
color_distance() {
    local r1=$1 g1=$2 b1=$3
    local r2=$4 g2=$5 b2=$6
    echo $(( (r1-r2)**2 + (g1-g2)**2 + (b1-b2)**2 ))
}

# Find the 8 best ANSI color matches from the palette
find_best_ansi_matches() {
    declare -a palette_colors=("${!1}")
    declare -a best_matches
    declare -A used_ansi_codes

    # Predefined ANSI 256-color cube (16-231) + grayscale (232-255)
    for ansi_code in {16..255}; do
        # Skip if we already have 8 matches
        if [[ ${#best_matches[@]} -ge 8 ]]; then
            break
        fi

        # Convert ANSI code to RGB
        if [[ $ansi_code -lt 232 ]]; then
            # Color cube
            local idx=$((ansi_code - 16))
            local r=$((idx / 36 * 51))
            local g=$(( (idx % 36) / 6 * 51 ))
            local b=$(( (idx % 6) * 51 ))
        else
            # Grayscale
            local gray=$(( (ansi_code - 232) * 10 + 8 ))
            local r=$gray g=$gray b=$gray
        fi

        # Find the closest palette color to this ANSI color
        local min_distance=999999
        local best_match=""
        for palette_color in "${palette_colors[@]}"; do
            read -r pr pg pb pname <<< "$palette_color"
            local distance=$(color_distance $r $g $b $pr $pg $pb)
            if [[ $distance -lt $min_distance ]]; then
                min_distance=$distance
                best_match="$pr $pg $pb $pname"
            fi
        done

        # Add to best matches if not already present
        if [[ -n "$best_match" && -z "${used_ansi_codes[$ansi_code]}" ]]; then
            best_matches+=("$ansi_code $best_match")
            used_ansi_codes[$ansi_code]=1
        fi
    done

    # Print the 8 best matches
    for match in "${best_matches[@]}"; do
        echo "$match"
    done
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
    local ansi_code="$1" r="$2" g="$3" b="$4" name="$5"
    local hex_code=$(rgb_to_hex "$r" "$g" "$b")
    printf "ANSI: %s | HEX: %s | RGB: %3d %3d %3d | %s\n" \
           "$(ansi_color "$ansi_code")" "$hex_code" "$r" "$g" "$b" "$name"
}

# Main script
main() {
    echo "GPL to 8 Best ANSI 256 Color Matches"

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

    # Parse colors
    declare -a palette_colors
    while read -r line; do
        palette_colors+=("$line")
    done < <(parse_gpl "$gpl_file")

    if [[ ${#palette_colors[@]} -eq 0 ]]; then
        echo "No colors found in the file or error parsing."
        return 1
    fi

    # Find and display the 8 best ANSI matches
    echo -e "\n8 Best ANSI Color Matches:"
    while read -r ansi_code r g b name; do
        format_output_line "$ansi_code" "$r" "$g" "$b" "$name"
    done < <(find_best_ansi_matches palette_colors[@])

    # Get output file path
    while true; do
        read -p $'\nEnter path to save output (relative or absolute, .txt): ' out_file
        if [[ -z "$out_file" ]]; then
            echo "Please enter a file path."
            continue
        fi
        if [[ ! "$out_file" =~ \.txt$ ]]; then
            out_file="${out_file}.txt"
        fi
        out_dir=$(dirname "$out_file")
        if [[ -n "$out_dir" && ! -d "$out_dir" ]]; then
            echo "Directory '$out_dir' does not exist. Please try again."
            continue
        fi
        break
    done

    # Save output
    echo "8 Best ANSI Color Matches:" > "$out_file"
    while read -r ansi_code r g b name; do
        format_output_line "$ansi_code" "$r" "$g" "$b" "$name" | sed -r "s/\x1B\[[0-9;]*[mK]//g" >> "$out_file"
    done < <(find_best_ansi_matches palette_colors[@])

    echo -e "\nOutput saved to: $(realpath "$out_file")"
}

main "$@"