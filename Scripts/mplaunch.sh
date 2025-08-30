#!/bin/bash

# Directories to check
DIR1_TO_CHECK="/home/operator/DataForts/ALPHA-II/ALAC"
DIR2_TO_CHECK="/home/operator/Music"

# Command to execute if either directory exists
COMMAND_TO_RUN="mocp"

# Check if either directory exists
if [ -d "$DIR1_TO_CHECK" ] || [ -d "$DIR2_TO_CHECK" ]; then
    echo "Either $DIR1_TO_CHECK or $DIR2_TO_CHECK exists."
    eval "$COMMAND_TO_RUN"
else
    echo "Neither $DIR1_TO_CHECK nor $DIR2_TO_CHECK exists."
fi
