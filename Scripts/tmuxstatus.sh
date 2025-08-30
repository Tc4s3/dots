#!/bin/bash
 
#Mnemosyne dock check

SESSION_NAME="T1"  

if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "T1: 0NL1N3"
else
    echo "T1: 0FFL1N3"
fi

