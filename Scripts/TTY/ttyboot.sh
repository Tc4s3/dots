#!/bin/bash

######TTY DOCKING SEQUENCE######
######LAUNCH ACTIONS######
tmux new -s "TTY" -d
    tmux split-pane -h
    tmux selectp -t 
        tmux send-keys -t "2" 'vim' Enter
    tmux selectp -t 1
    tmux split-pane -v
        tmux send-keys -t "3" 'vifm' Enter
        tmux send-keys -t "3" ':colorscheme Default' Enter
    tmux new-window 
    tmux selectw -t 4
        tmux send-keys -t "4" 'mp' Enter
    tmux new-window 
    tmux selectw -t 5
        tmux send-keys -t "5" 'htop' Enter
    tmux selectw -t 1 
        tmux send-keys -t "1" 'ud' Enter
    tmux attach-session -t "TTY"
