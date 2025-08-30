#!/bin/bash

# Script: myscript.sh
# Description: i3 session management script
# Usage: ./myscript.sh -[OPTION]

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
WALLPAPER="/home/operator/Pictures/namibia2kpxlD.png"

# Function to display help
show_help() {
    echo -e "${GREEN}Usage: ${0} -[OPTION]${NC}"
    echo -e "Session management options:"
    echo -e "  -l, --lock       Lock the screen"
    echo -e "  -s, --sleep      Suspend and lock"
    echo -e "  -o, --logout     Logout from i3"
    echo -e "  -p, --poweroff   Shutdown immediately"
    echo -e "  -h, --help       Show this help message"
    echo -e ""
    echo -e "Examples:"
    echo -e "  ${0} -l      # Lock screen"
    echo -e "  ${0} --sleep # Suspend and lock"
}

# Function to lock screen
lock_screen() {
    echo -e "${BLUE}Locking screen...${NC}"
    i3lock -i "$WALLPAPER" -t
}

# Function to suspend and lock
suspend_and_lock() {
    echo -e "${BLUE}Suspending system and locking screen...${NC}"
    systemctl suspend && i3lock -i "$WALLPAPER" -t
}

# Function to logout
logout() {
    echo -e "${YELLOW}Requesting logout...${NC}"
    i3-nagbar -t warning -m 'Exit i3?' -B 'Yes' 'i3-msg exit'
}

# Function to shutdown
shutdown_system() {
    echo -e "${RED}Shutting down system immediately...${NC}"
    read -p "Are you sure you want to shutdown? (y/N): " confirm
    case $confirm in
        [yY]|[yY][eE][sS])
            shutdown now
            ;;
        *)
            echo -e "${GREEN}Shutdown cancelled.${NC}"
            exit 0
            ;;
    esac
}

# Check if no arguments provided
if [[ $# -eq 0 ]]; then
    echo -e "${RED}Error: No option specified${NC}"
    show_help
    exit 1
fi

# Parse command line arguments
case $1 in
    -l|--lock)
        lock_screen
        ;;
    -s|--sleep)
        suspend_and_lock
        ;;
    -o|--logout)
        logout
        ;;
    -p|--poweroff)
        shutdown_system
        ;;
    -h|--help)
        show_help
        ;;
    *)
        echo -e "${RED}Error: Unknown option '$1'${NC}"
        show_help
        exit 1
        ;;
esac

exit 0
