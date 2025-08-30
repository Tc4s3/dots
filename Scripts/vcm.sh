#!/bin/bash

# Ask if the user wants to mount data fortresses
read -p "Mount DataFortresses? (y/n) " mount_response

if [[ $mount_response == "y" ]]; then
    echo "MOUNTING DATAFORTS"
    if  sudo veracrypt -m=nokernelcrypto /mnt/ADRIVE/DATAFORT /home/operator/DataForts/ALPHA-I && 
        sudo veracrypt -m=nokernelcrypto /mnt/ADRIVE/DATAFORT-II /home/operator/DataForts/ALPHA-II &&
        sudo veracrypt -m=nokernelcrypto /mnt/BDRIVE/DATAFORT /home/operator/DataForts/BETA-I &&
        sudo veracrypt -m=nokernelcrypto /mnt/BDRIVE/DATAFORT-II /home/operator/DataForts/BETA-II 
    then
        exa -aTL 1 ~/DataForts/
        echo "DATAFORTS MOUNTED"
    else 
        echo "MOUNTING FAILED"
    fi
elif [[ $mount_response == "n" ]]; then
    echo "Datafortresses not mounted."
else
    echo "Invalid input. Exiting."
    exit 1
fi

echo "All operations complete.";
