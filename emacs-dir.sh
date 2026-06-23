#!/bin/bash
# Open emacs with dired in two panes
# Two optional arguments can be passed to specify the directories to open
# If no arguments are passed, the current directory will be used

CURRENT_DIR=.

DIR_ONE=${1:-$CURRENT_DIR}
DIR_TWO=${2:-$CURRENT_DIR}

# For reference, from https://stackoverflow.com/a/11266635/4612064:
# emacs -nw financial_accounts.txt -f split-window-horizontally financial_budget.txt -f split-window-vertically financial_taxes.txt -f other-window -f split-window-vertically financial_tasks.txt -f other-window -f other-window -f other-window'

emacs -nw --no-desktop "$DIR_ONE" -f split-window-vertically "$DIR_TWO"
