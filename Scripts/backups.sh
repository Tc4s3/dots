#!/bin/bash

#########################################
###░▒█▀▀▄░█▀▀▄░▒█▀▀▄░▒█░▄▀░▒█░▒█░▒█▀▀█###
###░▒█▀▀▄▒█▄▄█░▒█░░░░▒█▀▄░░▒█░▒█░▒█▄▄█###
###░▒█▄▄█▒█░▒█░▒█▄▄▀░▒█░▒█░░▀▄▄▀░▒█░░░###
#########################################

echo "INITIATING BACKUP"
echo "..."
sleep 1
#########################################
### BACKUP PROCESS ######################
#########################################

echo "ERASING DESTINATION"
mkdir -p /tmp/emptydir
sudo rsync -a --delete --progress /tmp/emptydir/ /home/operator/DataForts/Backups/
rmdir /tmp/emptydir
echo "BUILDING FS"
sudo mkdir /home/operator/DataForts/Backups/BACKUPS &&
if echo "CONFIRMING NEW FS"
    sleep 0.5
    exa -aTL 2 /home/operator/DataForts/Backups; 
     ~/Scripts/ud.sh &&
    echo "BACKING UP PKGS"
    sudo pacman -Q|cut -f 1 -d " " > ~/Scripts/MN3M05YN3V2/pkglst.txt &&
    sleep 0.5
    sudo rsync --progress ~/Scripts/MN3M05YN3V2/pkglst.txt /home/operator/DataForts/Backups &&
    echo "..."
    sleep 0.5
    echo "CONFIRMING PKG BU"
    exa -aTL 1 /home/operator/DataForts/Backups &&
    echo "..." 
    sleep 0.5
    echo "BACKING UP HOME DIR"
    rsync -avh --progress \
        .bash_history \
        .bash_logout \
        .bash_profile \
        .bashrc \
        .bitwarden-ssh-agent.sock \
        ~/.config \
        .fonts.conf \
        ~/.gnupg \
        .gtkrc-2.0 \
        ~/.icons \
        ~/.librewolf \
        ~/.moc \
        ~/.mozilla \
        ~/.nv \
        ~/.pki \
        .pulse-cookie \
        ~/.ssh \
        .steampath \
        .steampid \
        ~/.tmux \
        ~/.vim \
        .viminfo \
        .vimrc \
        ~/Documents \
        ~/Downloads \
        fflogo.txt \
        ~/Fonts \
        ~/Gits \
        ~/Pictures \
        ~/Scripts \
        ~/Videos \
    /home/operator/DataForts/Backups/BACKUPS
then
    # Save command history
    history_file=/home/operator/DataForts/Backups/backup_history_$(date +%Y%m%d_%H%M%S).txt
    history > "$history_file"
    echo "LOG SAVED: $history_file"
    exa -aTL 2 /home/operator/DataForts/Backups && 
    echo "BACKUP COMPLETE. PLEASE MOVE REMAINING FILES MANUALLY."
else 
    echo "BACKUP FAILED"
fi
