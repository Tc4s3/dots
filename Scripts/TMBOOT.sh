#!/bin/bash

######MN3M05YN3 DOCKING SEQUENCE######
######LAUNCH ACTIONS######
tmux new -s "T1" -d
    tmux new-window
    tmux selectw -t 2
        tmux rename-window -t "2" ' vim'
        tmux send-keys -t "2" 'vim' Enter
    tmux new-window
    tmux selectw -t 3
        tmux rename-window -t "3" ' vifm'
        tmux send-keys -t "3" 'vifm' Enter
    tmux new-window 
    tmux selectw -t 4
        tmux rename-window -t "4" ' mocp'
        tmux send-keys -t "4" 'mp' Enter
    tmux selectw -t 1 
        tmux splitw -h -t 1
            tmux send-keys -t 1.2 'btop' Enter  # Directly target pane 1.2
            tmux send-keys -t 1.1 'tbm' Enter   # Directly target pane 1.1
            tmux rename-window -t 1 ' bash ¦ 󱡶 btop'
        tmux selectp -t 1.1
    tmux attach-session -t "T1"
