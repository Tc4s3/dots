#!/bin/bash

hex_to_rgb() {
    local hex="$1"
    [[ ${hex} == "#"* ]] && hex="${hex:1}"
    [[ ${#hex} == 3 ]] && hex="${hex:0:1}${hex:0:1}${hex:1:1}${hex:1:1}${hex:2:1}${hex:2:1}"
    echo "$((16#${hex:0:2})) $((16#${hex:2:2})) $((16#${hex:4:2}))"
}

find_closest_ansi() {
    local r=$1 g=$2 b=$3 min_dist=999999 closest_code=0
    
    for code in {0..15}; do
        case $code in
            0)  cr=0;    cg=0;    cb=0;;    1)  cr=205;  cg=0;    cb=0;;
            2)  cr=0;    cg=205;  cb=0;;    3)  cr=205;  cg=205;  cb=0;;
            4)  cr=0;    cg=0;    cb=238;;   5)  cr=205;  cg=0;    cb=205;;
            6)  cr=0;    cg=205;  cb=205;;   7)  cr=229;  cg=229;  cb=229;;
            8)  cr=127;  cg=127;  cb=127;;   9)  cr=255;  cg=0;    cb=0;;
            10) cr=0;    cg=255;  cb=0;;    11) cr=255;  cg=255;  cb=0;;
            12) cr=92;   cg=92;   cb=255;;  13) cr=255;  cg=0;    cb=255;;
            14) cr=0;    cg=255;  cb=255;;  15) cr=255;  cg=255;  cb=255;;
        esac
        (( (r-cr)**2 + (g-cg)**2 + (b-cb)**2 < min_dist )) && { 
            min_dist=$(( (r-cr)**2 + (g-cg)**2 + (b-cb)**2 ))
            closest_code=$code
        }
    done

    for code in {16..231}; do
        base=$((code - 16))
        cr=$(( (base / 36) > 0 ? 55 + (base / 36) * 40 : 0 ))
        cg=$(( ( (base % 36) / 6 ) > 0 ? 55 + ( (base % 36) / 6 ) * 40 : 0 ))
        cb=$(( (base % 6) > 0 ? 55 + (base % 6) * 40 : 0 ))
        (( (r-cr)**2 + (g-cg)**2 + (b-cb)**2 < min_dist )) && {
            min_dist=$(( (r-cr)**2 + (g-cg)**2 + (b-cb)**2 ))
            closest_code=$code
        }
    done

    for code in {232..255}; do
        gray=$(( (code - 232) * 10 + 8 ))
        (( (r-gray)**2 + (g-gray)**2 + (b-gray)**2 < min_dist )) && {
            min_dist=$(( (r-gray)**2 + (g-gray)**2 + (b-gray)**2 ))
            closest_code=$code
        }
    done

    echo $closest_code
}

interpolate_color() {
    local r1=$1 g1=$2 b1=$3 r2=$4 g2=$5 b2=$6 factor=$7
    r=$(echo "scale=0; $r1 + ($r2 - $r1) * $factor" | bc -l)
    g=$(echo "scale=0; $g1 + ($g2 - $g1) * $factor" | bc -l)
    b=$(echo "scale=0; $b1 + ($b2 - $b1) * $factor" | bc -l)
    r=${r%.*}; g=${g%.*}; b=${b%.*}
    (( r < 0 )) && r=0; (( r > 255 )) && r=255
    (( g < 0 )) && g=0; (( g > 255 )) && g=255
    (( b < 0 )) && b=0; (( b > 255 )) && b=255
    echo "$r $g $b"
}

rgb_to_hex() { printf "#%02x%02x%02x" "$1" "$2" "$3"; }

export_to_gpl() {
    echo -e "\nExporting gradient to GIMP Palette (GPL) file..."
    read -p "Enter a name for your palette: " palette_name
    read -p "Enter directory to save (default: current directory): " save_dir
    [ -z "$save_dir" ] && save_dir="."
    filename="${save_dir}/${palette_name// /_}.gpl"
    
    echo "GIMP Palette" > "$filename"
    echo "Name: $palette_name" >> "$filename"
    echo "Columns: 4" >> "$filename"
    echo "#" >> "$filename"
    
    for i in "${!gradient_colors[@]}"; do
        rgb=($(hex_to_rgb "${gradient_colors[i]}"))
        printf "%-3d %-3d %-3d Color %02d\n" "${rgb[0]}" "${rgb[1]}" "${rgb[2]}" "$((i+1))" >> "$filename"
    done
    
    hex_filename="${save_dir}/${palette_name// /_}_hex.txt"
    for color in "${gradient_colors[@]}"; do echo "$color" >> "$hex_filename"; done
    echo -e "\n\e[32mPalette saved to: $filename\e[0m"
    echo -e "\e[32mHex codes saved to: $hex_filename\e[0m"
}

clear
echo "Hex Color Gradient Generator"
echo "==========================="

while true; do
    read -p "How many colors in your gradient? (2/3/4): " color_count
    [[ $color_count =~ ^[234]$ ]] && break
    echo "Please enter 2, 3, or 4"
done

echo -e "\nEnter hex color values (e.g., #FF0000 #00FF00 #0000FF)"
colors=()
for ((i=1; i<=color_count; i++)); do
    read -p "Color $i: " color
    colors+=("$color")
done

while true; do
    read -p "Gradient size (16 or 8 cells)? (16/8): " gradient_size
    [[ $gradient_size == 16 || $gradient_size == 8 ]] && break
    echo "Please enter 16 or 8"
done

rgb_values=()
ansi_codes=()
for color in "${colors[@]}"; do
    rgb=($(hex_to_rgb "$color"))
    rgb_values+=("${rgb[@]}")
    ansi=$(find_closest_ansi ${rgb[0]} ${rgb[1]} ${rgb[2]})
    ansi_codes+=("$ansi")
done

echo -e "\nClosest ANSI matches:"
for i in "${!colors[@]}"; do
    echo -e "Color $((i+1)): \e[38;5;${ansi_codes[i]}m${colors[i]} (ANSI ${ansi_codes[i]})\e[0m"
done

gradient_colors=()
gradient_ansi=()
steps=$((gradient_size/(color_count-1)-1))

for ((seg=0; seg<color_count-1; seg++)); do
    r1=${rgb_values[seg*3]}
    g1=${rgb_values[seg*3+1]}
    b1=${rgb_values[seg*3+2]}
    r2=${rgb_values[seg*3+3]}
    g2=${rgb_values[seg*3+4]}
    b2=${rgb_values[seg*3+5]}
    
    for i in $(seq 0 $steps); do
        factor=$(echo "scale=2; $i/$steps" | bc)
        rgb=($(interpolate_color $r1 $g1 $b1 $r2 $g2 $b2 $factor))
        hex=$(rgb_to_hex ${rgb[0]} ${rgb[1]} ${rgb[2]})
        ansi=$(find_closest_ansi ${rgb[0]} ${rgb[1]} ${rgb[2]})
        gradient_colors+=("$hex")
        gradient_ansi+=("$ansi")
    done
done

echo -e "\nGradient Preview (${gradient_size}-cell):"
for i in "${!gradient_colors[@]}"; do printf "\e[48;5;${gradient_ansi[i]}m  \e[0m"; done
echo -e "\n"

echo "Hex       ANSI"
echo "--------  ----"
for i in "${!gradient_colors[@]}"; do
    printf "\e[38;5;${gradient_ansi[i]}m%-9s %3d\e[0m\n" "${gradient_colors[i]}" "${gradient_ansi[i]}"
done

while true; do
    read -p $'\nExport this gradient to files? (y/n) ' yn
    case $yn in
        [Yy]* ) export_to_gpl; break;;
        [Nn]* ) echo -e "\nDone!"; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
