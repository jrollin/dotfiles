#!/bin/bash
tmux new-session -s Coding -n sources -d

tmux new-window -t Coding -n term -d

tmux select-window -t Coding:sources

tmux select-window -t Coding:term 
tmux split-window -h

tmux select-window -t Coding:sources
tmux -u attach -t Coding


