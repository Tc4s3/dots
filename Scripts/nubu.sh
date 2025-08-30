#!/bin/bash

###########################################
### Robust Home Directory Backup Script ###
###########################################

# Configuration
BACKUP_MOUNT_POINT="/home/operator/DataForts/Backups"  # Exact mount point
BACKUP_DIR="$BACKUP_MOUNT_POINT/BACKUPS_$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$BACKUP_MOUNT_POINT/backup_$(date +%Y%m%d_%H%M%S).log"
PKG_LIST="$BACKUP_MOUNT_POINT/pkglist_$(date +%Y%m%d).txt"

# Files and directories to backup
BACKUP_ITEMS=(
    .bash_history .bash_logout .bash_profile .bashrc
    .config .fonts.conf .gnupg .gtkrc-2.0 .icons
    .librewolf .moc .mozilla .nv .pki .ssh
    .tmux .vim .viminfo .vimrc
    Documents Downloads Fonts Gits Pictures Scripts Videos
)

# Ensure important variables are set
HOME_DIR="$HOME"

# Functions
check_mount_point() {
    if ! mountpoint -q "$BACKUP_MOUNT_POINT"; then
        echo "ERROR: Backup device not mounted at $BACKUP_MOUNT_POINT"
        echo "Please mount with: mount /dev/[your_device] $BACKUP_MOUNT_POINT"
        exit 1
    fi
    
    # Verify write permissions
    if ! touch "$BACKUP_MOUNT_POINT"/mount_test 2>/dev/null; then
        echo "ERROR: No write permissions in $BACKUP_MOUNT_POINT"
        exit 1
    fi
    rm -f "$BACKUP_MOUNT_POINT"/mount_test
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

check_dependencies() {
    local missing=()
    for cmd in rsync mountpoint; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        log "ERROR: Missing required commands: ${missing[*]}"
        exit 1
    fi
}

validate_paths() {
    if [ ! -d "$HOME_DIR" ]; then
        log "ERROR: Home directory $HOME_DIR does not exist"
        exit 1
    fi
}

create_backup_dir() {
    log "Creating backup directory: $BACKUP_DIR"
    if ! mkdir -p "$BACKUP_DIR"; then
        log "ERROR: Failed to create backup directory"
        exit 1
    fi
}

backup_package_list() {
    log "Backing up package list to $PKG_LIST"
    if pacman -Q | cut -f 1 -d " " > "$PKG_LIST"; then
        log "Package list backup completed successfully"
    else
        log "WARNING: Failed to create package list"
    fi
}

perform_backup() {
    log "Starting backup of home directory items"
    
    local errors=0
    for item in "${BACKUP_ITEMS[@]}"; do
        local source="$HOME_DIR/$item"
        if [ -e "$source" ]; then
            log "Backing up: $item"
            if ! rsync -aRh --progress "$source" "$BACKUP_DIR/"; then
                log "WARNING: Failed to backup $item"
                ((errors++))
            fi
        else
            log "NOTICE: $item does not exist, skipping"
        fi
    done
    
    if [ $errors -gt 0 ]; then
        log "WARNING: Backup completed with $errors errors"
    else
        log "Backup completed successfully"
    fi
}

cleanup() {
    log "Backup completed. Backup location: $BACKUP_DIR"
    log "Log file saved to: $LOG_FILE"
    
    # Show summary
    echo -e "\n=== Backup Summary ==="
    echo "Backup location: $BACKUP_DIR"
    echo "Total size: $(du -sh "$BACKUP_DIR" | cut -f1)"
    echo "Log file: $LOG_FILE"
}

### Main Execution ###
{
    echo "Starting backup process..."
    check_mount_point       # First verify mount
    check_dependencies
    validate_paths
    create_backup_dir
    backup_package_list
    perform_backup
    cleanup
} | tee -a "$LOG_FILE"

exit 0