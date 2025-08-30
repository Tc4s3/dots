#!/bin/bash

######MN3M05YN3_R38U1LD######
if
    echo "R38U1LD C0MM3NC1N9"
    echo "..."
    echo "S3TT1N9 3NV170M3NT" &&
    #set environment
    sudo chsh -s /usr/bin/bash &&
    chsh -s /usr/bin/bash && 
    source ~/.bashrc &&
    echo "3NV170M3NT 53T" &&
    #get YAY
    sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si &&
    #install pkgs from file
    sudo pacman -S --needed $(comm -12 <(pacman -Slq | sort) <(sort /run/media/operator/Backups/pkglist.txt)) &&
    #copy files from /run/media/operator/Backups to ~/
    sudo rsync -rP /run/media/operator/Backups/BACKUPS ~/ &&
    #make scripts executable
    sudo chmod +x ~/Scripts/*.sh &&
    #run update, build DF Dir, Attach DataForts
    ./Scripts/DF-FS.sh && ./Scripts/update.sh 
    echo "R381LD 5UC355FUL"
    sleep 0.5
    echo "..."
    sleep 0.5
    echo "W3LC4M3 B4CK 0P374T07, PL34S3 M1GR74T3 4NY R3M41N1NG D4T4"
else
    "R38U1LD F4IL3D"
fi
