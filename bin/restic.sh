#!/bin/bash

# Dir needs 2 files: include.txt, exclude.txt that will be passed to restic
# Optionally save files in "unencrypted.txt" to $RESTIC_REPOSITORY/../Documents/
DIRR=$HOME/.config/restic
export RESTIC_REPOSITORY=$1
export RESTIC_PASSWORD_COMMAND='secret-tool lookup Title "Restic Backup"'

_=$(eval $RESTIC_PASSWORD_COMMAND)
if [ $? != 0 ]; then
	echo "Could not get restic password (\"Restic Backup\"). Is secret-tool unlocked?"
	exit 1;
fi

if [ "$1" == "init" ]; then
	restic init
	exit
fi

restic backup --files-from $DIRR/include.txt --exclude-file $DIRR/exclude.txt

# Copy some files directly
if [ -f "$DIRR/unencrypted.txt" ]; then
    cp -r $(echo `cat $DIRR/unencrypted.txt`) $RESTIC_REPOSITORY/../Documents/
fi