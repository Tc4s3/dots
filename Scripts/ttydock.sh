#!/bin/bash

###TTY DOCKING SEQUENCE###

tmux new -s "TTY" -d
    tmux splitp -v
    tmux splitp -h
    tmux selectp -t 1
    tmux splitp -h
    tmux new-window -t 2
    tmux selectw -t 1
    tmux selectp -t 2
        tmux send-keys -t "2" 'vim' Enter
    tmux selectp -t 3
        tmux send-keys -t "3" 'mp' Enter
    tmux selectp -t 4 
        tmux send-keys -t "4" 'vifm' Enter
    tmux selectw -t 2
        tmux send-keys -t "2" 'btop' Enter 
    tmux selectw -t 1
         tmux selectp -t 1
             tmux send-keys -t "1" 'ud' Enter
tmux attach-session -t "TTY" 
