#!/bin/bash

# Audio sink names
LAPTOP_SINK="alsa_output.pci-0000_05_00.6.analog-stereo"
HDMI_SINK="alsa_output.pci-0000_01_00.1.hdmi-stereo"

# Get current default sink
CURRENT_SINK=$(pactl get-default-sink)

# Determine which sink to switch to
if [ "$CURRENT_SINK" == "$LAPTOP_SINK" ]; then
    NEW_SINK=$HDMI_SINK
    echo "Switching to HDMI audio"
else
    NEW_SINK=$LAPTOP_SINK
    echo "Switching to laptop audio"
fi

# Set the new default sink
pactl set-default-sink "$NEW_SINK"

# Move all existing inputs to the new sink
pactl list short sink-inputs | while read line; do
    INPUT_ID=$(echo "$line" | awk '{print $1}')
    pactl move-sink-input "$INPUT_ID" "$NEW_SINK"
done

echo "Audio output switched to $NEW_SINK"
