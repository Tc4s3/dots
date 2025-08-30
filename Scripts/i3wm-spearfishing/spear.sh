#!/usr/bin/env bash

# Configuration
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/i3-workspace-register"
REGISTER_FILE="$CONFIG_DIR/register"
MONITOR="DP-1"  # Change to your target monitor (check with `i3-msg -t get_outputs`)

# Initialize if not exists
mkdir -p "$CONFIG_DIR"
if [[ ! -f "$REGISTER_FILE" ]]; then
    echo "primary:" > "$REGISTER_FILE"
    echo "secondary:" >> "$REGISTER_FILE"
fi

# Helper functions
read_register() {
    local primary secondary
    primary=$(grep '^primary:' "$REGISTER_FILE" | cut -d: -f2- | sed 's/^ *//')
    secondary=$(grep '^secondary:' "$REGISTER_FILE" | cut -d: -f2- | sed 's/^ *//')
    echo "$primary,$secondary"
}

update_register() {
    local primary="$1"
    local secondary="$2"
    echo "primary: $primary" > "$REGISTER_FILE"
    echo "secondary: $secondary" >> "$REGISTER_FILE"
}

get_current_workspace() {
    i3-msg -t get_workspaces | while read -r line; do
        if [[ "$line" == *"\"focused\":true"* ]]; then
            local ws_name=$(echo "$line" | grep -oP '"name":"\K[^"]+')
            echo "$ws_name"
            break
        fi
    done
}

get_workspace_output() {
    local ws="$1"
    i3-msg -t get_workspaces | while read -r line; do
        if [[ "$line" == *"\"name\":\"$ws\""* ]]; then
            local output=$(echo "$line" | grep -oP '"output":"\K[^"]+')
            echo "$output"
            break
        fi
    done
}

# Core functions
add_to_register() {
    local ws="$1"
    local current_output
    
    current_output=$(get_workspace_output "$ws")
    
    if [[ "$current_output" != "$MONITOR" ]]; then
        echo "Error: Workspace $ws is not on monitor $MONITOR"
        return 1
    fi
    
    IFS=',' read -r primary secondary <<< "$(read_register)"
    
    if [[ -z "$primary" ]]; then
        update_register "$ws" "$secondary"
    elif [[ "$primary" == "$ws" || "$secondary" == "$ws" ]]; then
        echo "Workspace already in register"
        return 0
    elif [[ -z "$secondary" ]]; then
        update_register "$primary" "$ws"
    else
        update_register "$primary" "$ws"
    fi
    
    echo "Added $ws to register"
}

remove_from_register() {
    local ws="$1"
    IFS=',' read -r primary secondary <<< "$(read_register)"
    
    if [[ "$primary" == "$ws" ]]; then
        if [[ -n "$secondary" ]]; then
            # Promote secondary to primary
            update_register "$secondary" ""
        else
            update_register "" ""
        fi
    elif [[ "$secondary" == "$ws" ]]; then
        update_register "$primary" ""
    else
        echo "Workspace not in register"
        return 1
    fi
    
    echo "Removed $ws from register"
}

toggle_workspaces() {
    local current_ws
    current_ws=$(get_current_workspace)
    
    IFS=',' read -r primary secondary <<< "$(read_register)"
    
    if [[ -z "$primary" || -z "$secondary" ]]; then
        echo "Register needs both primary and secondary workspaces to toggle"
        return 1
    fi
    
    if [[ "$current_ws" == "$primary" ]]; then
        i3-msg "workspace $secondary" > /dev/null
    elif [[ "$current_ws" == "$secondary" ]]; then
        i3-msg "workspace $primary" > /dev/null
    else
        # Current workspace isn't in register, go to primary
        i3-msg "workspace $primary" > /dev/null
    fi
}

# Main command handler
case "$1" in
    add)
        if [[ -z "$2" ]]; then
            echo "Usage: $0 add <workspace>"
            exit 1
        fi
        add_to_register "$2"
        ;;
    remove)
        if [[ -z "$2" ]]; then
            echo "Usage: $0 remove <workspace>"
            exit 1
        fi
        remove_from_register "$2"
        ;;
    toggle)
        toggle_workspaces
        ;;
    status)
        IFS=',' read -r primary secondary <<< "$(read_register)"
        echo "Primary: $primary"
        echo "Secondary: $secondary"
        ;;
    *)
        echo "Usage: $0 {add|remove|toggle|status} [workspace]"
        exit 1
        ;;
esac