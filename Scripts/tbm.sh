#!/bin/bash

# Ask if the user wants to perform a system update
read -p "Perform Update? (y/n) " update_response

if [[ $update_response == "y" ]]; then
    echo "UPDATING SYSTEM"
    if  
        ~/Scripts/ud.sh
    then
        echo "UPDATE COMPLETE"
    else 
        echo "UPDATE FAILED"
    fi
elif [[ $update_response == "n" ]]; then
    echo "Update skipped."
else
    echo "Invalid input. Exiting."
    exit 1
fi

sleep 1.5 

# Run med.sh script before continuing
echo "Running med.sh script..."
if /home/operator/Scripts/med.sh; then
    echo "med.sh completed successfully."
else
    echo "med.sh failed. Exiting."
    exit 1
fi

# Directories to check
DIRS_TO_CHECK=(
    "/mnt/ADRIVE"
    "/mnt/BDRIVE"
)

# Command to execute if both directories exist
COMMAND_TO_RUN="/home/operator/Scripts/vcm.sh"

# Check if all directories exist
for DIR in "${DIRS_TO_CHECK[@]}"; do
    if [ ! -d "$DIR" ]; then
        echo "$DIR does not exist."
        exit 1
    fi
done

# If script reaches this point, all directories exist
echo "All required directories exist."
eval "$COMMAND_TO_RUN"

echo "All operations complete.";
sleep 1.5
clear
