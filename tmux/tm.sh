#!/bin/bash

SNAME="${1:-coding}"
echo $SNAME
# name session and window
tmux new-session -s $SNAME -n sources -d

# create new named window
tmux new-window -t $SNAME -n term -d

# select window and split
tmux select-window -t $SNAME:term 
tmux split-window -h
# cmd
tmux send-keys -t $SNAME:term "git status" Enter

# select window
tmux select-window -t $SNAME:sources
tmux -u attach -t $SNAME


