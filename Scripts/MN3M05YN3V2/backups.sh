#!/bin/bash
#########################################
###░▒█▀▀▄░█▀▀▄░▒█▀▀▄░▒█░▄▀░▒█░▒█░▒█▀▀█###
###░▒█▀▀▄▒█▄▄█░▒█░░░░▒█▀▄░░▒█░▒█░▒█▄▄█###
###░▒█▄▄█▒█░▒█░▒█▄▄▀░▒█░▒█░░▀▄▄▀░▒█░░░###
#########################################
#
# Simple Script to routinley nake snapsnot backups of the core system for system restoration if neccesary
# As of 15/05/24 system is base of vanilla arch w/KDE Plasma 6
echo "INITIATING BACKUP"
echo "..."
echo "ERASING DESTINATION"
sudo rm -rf /run/media/operator/Backups/* &&
echo "BUILDING FS"
mkdir /run/media/operator/Backups/BACKUPS &&
if echo "CONFIRMING NEW FS"
   sleep 0.5
   exa -aTL 2 /run/media/operator/Backups; 
  ~/Scripts/update.sh &&
   echo "BACKING UP PKGS"
   sudo pacman -Q|cut -f 1 -d " " > ~/Scripts/MN3M05YN3V1.0/pkglst.txt &&
   sleep 0.5
   sudo rsync --progress ~/Scripts/MN3M05YN3V1.0/pkglst.txt /run/media/operator/Backups &&
   echo "..."
   sleep 0.5
   echo "..."
   sleep 0.5
   echo "BACKING UP HOME DIR"
   sudo rsync -r --info=progress2 --exclude 'DataForts' --exclude 'Music' --exclude 'Videos' ~/* /run/media/operator/Backups/BACKUPS &&
   sudo rsync -r --info=progress2 ~/.config /run/media/operator/Backups/BACKUPS &&
   sudo rsync -r --info=progress2 ~/.moc /run/media/operator/Backups/BACKUPS/ &&
   sudo rsync -r --info=progress2 ~/.librewolf /run/media/operator/Backups/BACKUPS/ &&
   sudo rsync -rP ~/.tmux /run/media/operator/Backups/BACKUPS/ &&
   sudo rsync --progress ~/.* /run/media/operator/Backups/BACKUPS/ 
then
    exa -aTL 2 /run/media/operator/Backups && 
    echo "BACKUP COMPLETE"  
else 
    echo "BACKUP FAILED"
fi
