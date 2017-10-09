#!/usr/local/bin/env bash

# Attribution: https://github.com/pablito56/devel_scripts/tree/master/auto_venv 

if [ -z "$VENV_FILE" ]; then
    VENV_FILE=".venv"
fi
if [ -z "$VENV_ROOT" ]; then
    VENV_ROOT="/Users/$USER/.virtualenvs"
fi
if [ -z "$VENV_BIN" ]; then
    VENV_BIN="bin/activate"
fi
if [ -z "$VENV_DEACT" ]; then
    VENV_DEACT="deactivate"
fi
if [ -z "$ACTIV_MSG" ]; then
    ACTIV_MSG='\033[0;32m   ACTIVATED Virtualenv'
fi
if [ -z "$DEACT_MSG" ]; then
    DEACT_MSG='\033[0;31m DEACTIVATED Virtualenv'
fi
DECOLOR='\033[00m'

# Check if given folder has Virtualenv
function set_folder_venv
{
    if [ -f $1"/"$VENV_FILE ]; then
        export CURR_VENV=$(cat $1"/"$VENV_FILE)
    else
        CURR_FOLDER=$(basename "$1")
#EDIT: Removed -- otherwise, checks if folder name matches venv name in root (venv_root)
#EDIT: I would just like to read .venv files with the name of a venv in it to run
#       if [ -d $VENV_ROOT"/"$CURR_FOLDER ]; then
#            export CURR_VENV=$CURR_FOLDER
#        fi
    fi
}

# Check recursively if current folders tree has Virtualenv
function set_curr_venv
{
    unset CURR_VENV
    FOLDER=$PWD
    while [ "$FOLDER" != "/" ]; do
        set_folder_venv $FOLDER
        if [ -n "$CURR_VENV" ]; then
            break
        fi
        FOLDER=$(dirname "$FOLDER")
    done
}

# Activate / deactivate Virtualenvs according to current path
function auto_venv
{
    unset OLD_VENV
    if [ -n "$VIRTUAL_ENV" ]; then
        OLD_VENV=$(basename "$VIRTUAL_ENV")
    fi
    set_curr_venv
    if [ "$OLD_VENV" != "$CURR_VENV" ]; then
        if [ -n "$OLD_VENV" ]; then
            $VENV_DEACT
            echo -e "$DEACT_MSG '$OLD_VENV'$DECOLOR"
        fi
        if [ -n "$CURR_VENV" ]; then
            if [ -f $VENV_ROOT"/"$CURR_VENV"/"$VENV_BIN ]; then
                #source $VENV_ROOT"/"$CURR_VENV"/"$VENV_BIN
                workon $CURR_VENV
                echo -e "$ACTIV_MSG '$CURR_VENV'$DECOLOR"
            else
                echo "AUTO_VENV ERROR: ACTIVATION SCRIPT NO FOUND '$VENV_ROOT"/"$CURR_VENV"/"$VENV_BIN'"
            fi
        fi
    fi
}

# Change folder and Activate / deactivate Virtualenvs
function auto_venv_cd
{
    cd "$@" && auto_venv
}

alias cd="auto_venv_cd"