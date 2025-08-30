#!/bin/bash

# Default settings
DEFAULT_APP=""
PREVIEW_PERCENT=60
USE_LOCATE=true
SEARCH_DRIVES="/"  # Default to root, but can be customized

# Parse command line arguments
while getopts "a:nld:h" opt; do
  case $opt in
    a)
      DEFAULT_APP="$OPTARG"
      ;;
    n)
      USE_LOCATE=false
      ;;
    l)
      USE_LOCATE=true
      ;;
    d)
      SEARCH_DRIVES="$OPTARG"
      ;;
    h)
      echo "Usage: fzf-file-search [-a application] [-n] [-l] [-d drives]"
      echo "  -a: Specify default application (e.g., firefox, gimp, vlc)"
      echo "  -n: Use find instead of locate (slower but more current)"
      echo "  -l: Use locate (faster, default)"
      echo "  -d: Specify drives to search (comma-separated, e.g. '/,/home')"
      echo "  -h: Show this help"
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Function to get files using locate with drive limitation
get_files_locate() {
    local drives=()
    IFS=',' read -ra drives <<< "$SEARCH_DRIVES"
    
    for drive in "${drives[@]}"; do
        # Clean up drive path
        drive=$(echo "$drive" | sed 's:/*$::')
        locate -i "$drive" 2>/dev/null | grep -v -E '/(proc|sys|dev|run|tmp|media|mnt|var/cache|var/tmp)/'
    done | sort -u
}

# Function to get files using find with drive limitation
get_files_find() {
    local drives=()
    IFS=',' read -ra drives <<< "$SEARCH_DRIVES"
    
    for drive in "${drives[@]}"; do
        # Clean up drive path
        drive=$(echo "$drive" | sed 's:/*$::')
        find "$drive" \
            -path "*/proc" -prune -o \
            -path "*/sys" -prune -o \
            -path "*/dev" -prune -o \
            -path "*/run" -prune -o \
            -path "*/tmp" -prune -o \
            -path "*/media" -prune -o \
            -path "*/mnt" -prune -o \
            -path "*/var/cache" -prune -o \
            -path "*/var/tmp" -prune -o \
            -type f -print 2>/dev/null
    done
}

# Calculate window height
TERM_HEIGHT=$(tput lines)
WINDOW_HEIGHT=$((TERM_HEIGHT * PREVIEW_PERCENT / 100))

# Function to preview files
preview_file() {
    local file="$1"
    if [ ! -r "$file" ]; then
        echo "=== Permission Denied ==="
        return
    fi
    
    if file "$file" | grep -q "text"; then
        echo "=== Text Preview ==="
        head -n 30 "$file"
    elif file "$file" | grep -q "image"; then
        echo "=== Image File ==="
        if command -v identify >/dev/null 2>&1; then
            identify "$file" 2>/dev/null | head -n 5
        else
            echo "Image file (install imagemagick for better preview)"
            echo "Size: $(du -h "$file" | cut -f1)"
        fi
    elif file "$file" | grep -q "PDF"; then
        echo "=== PDF File ==="
        if command -v pdfinfo >/dev/null 2>&1; then
            pdfinfo "$file" 2>/dev/null | head -n 10
        else
            echo "PDF document"
            echo "Size: $(du -h "$file" | cut -f1)"
        fi
    else
        echo "=== File Info ==="
        file "$file"
        echo -e "\nSize: $(du -h "$file" | cut -f1)"
        echo "Modified: $(stat -c %y "$file" 2>/dev/null | cut -d'.' -f1)"
    fi
}

export -f preview_file

# Get file list based on method
if [ "$USE_LOCATE" = true ]; then
    if ! command -v locate >/dev/null 2>&1; then
        echo "Error: locate command not found. Install plocate or mlocate."
        echo "Run: sudo pacman -S plocate"
        exit 1
    fi
    FILE_LIST=$(get_files_locate)
else
    FILE_LIST=$(get_files_find)
fi

# Use FZF to select file
SELECTED_FILE=$(echo "$FILE_LIST" | fzf \
    --height=$WINDOW_HEIGHT% \
    --preview='bash -c "preview_file {}"' \
    --preview-window=right:60% \
    --bind='ctrl-h:toggle-preview' \
    --bind='ctrl-a:execute(echo -n {} | xclip -selection clipboard 2>/dev/null || echo {} | wl-copy 2>/dev/null)' \
    --header="Drives: $SEARCH_DRIVES | Method: $([ "$USE_LOCATE" = true ] && echo "locate" || echo "find") | App: ${DEFAULT_APP:-default}")

# Open selected file
if [ -n "$SELECTED_FILE" ] && [ -e "$SELECTED_FILE" ]; then
    if [ -n "$DEFAULT_APP" ]; then
        echo "Opening '$SELECTED_FILE' with $DEFAULT_APP"
        xdg-open "$SELECTED_FILE" >/dev/null 2>&1 &
    else
        echo "Opening '$SELECTED_FILE' with default application"
        xdg-open "$SELECTED_FILE" >/dev/null 2>&1 &
    fi
elif [ -n "$SELECTED_FILE" ]; then
    echo "Error: File not found or inaccessible: '$SELECTED_FILE'"
fi