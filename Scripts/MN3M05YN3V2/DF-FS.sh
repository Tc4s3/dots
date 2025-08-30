#!/bin/bash

if
    sudo mkdir ~/DataForts
then
    sudo mkdir ~/DataForts/ALPHA-I
    sudo mkdir ~/DataForts/ALPHA-II
    sudo mkdir ~/DataForts/BETA-I
    sudo mkdir ~/DataForts/BETA-II
else
    echo "script failure"
fi
