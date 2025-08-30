#!/bin/bash
# Save original directory
original_dir="$(pwd)"

# Move to target directory
fixed_dir="/home/operator/Documents/RNNRDEV"
pushd "$fixed_dir" > /dev/null || { echo "Cannot cd to $fixed_dir"; exit 1; }

# Remove previous BU*.zip backups
echo "Cleaning up old backups..."
rm -fv BU*.zip  # -v shows what's being removed

# Create new backup
TIMESTAMP=$(date +"%Y%m%d_%H%M")
ZIP_NAME="BU_$TIMESTAMP.zip"

if zip -vr "$ZIP_NAME" ./*; 
then
echo -e "\nOverwriting remote directories with fresh backup..."
    
    # Delete existing directories first for clean overwrite
    sudo rm -rf ~/DataForts/ALPHA-II/RNNRDEV ~/DataForts/BETA-II/RNNRDEV
    
    # Sync with -rP (recursive + progress)
    sudo rsync -rP ~/Documents/RNNRDEV/ ~/DataForts/ALPHA-II/RNNRDEV/ &&
    sudo rsync -rP ~/Documents/RNNRDEV/ ~/DataForts/BETA-II/RNNRDEV/                                                              
                                                          
    echo -e "\nAll operations complete. Current backup:"
    ls -lh "$ZIP_NAME"&& # Show only the new backup

	exa -al ~/DataForts/ALPHA-II/RNNRDEV&&
	exa -al ~/DataForts/BETA-II/RNNRDEV&&
	du -sh ~/Documents/RNNRDEV/*;

else
    echo "Operations failed"
fi

# Return to the original directory
popd > /dev/null
echo "Back in: $(pwd)"
