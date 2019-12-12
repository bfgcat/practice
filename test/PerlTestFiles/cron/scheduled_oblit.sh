#!/bin/sh

# Get Parameters From Command Prompt
P4PORT=$1
P4USER=$2
P4CLIENT=$3

echo Perforce Obliterate Scheduled
echo =============================
echo
echo Database used: $P4PORT
echo -----------------------------------
echo CMD: p4 info
/perforce/bin/p4 -p $P4PORT -u $P4USER -c $P4CLIENT info
echo

echo Snap files
echo --------------------------------------
export START_TIME="Start:  `date +"%Y-%m-%d %H:%M:%S"`"
echo "COMMAND: /perforce/bin/p4 -p $P4PORT -u $P4USER -c $P4CLIENT snap //... //$P4CLIENT/..."
/perforce/bin/p4 -p $P4PORT -u $P4USER -c $P4CLIENT snap //... //$P4CLIENT/...
export FINISH_TIME="Finish: `date +"%Y-%m-%d %H:%M:%S"`"
echo "Start:  $START_TIME"
echo "Finish: $FINISH_TIME"
echo


echo Obliterate files
echo --------------------------------------
echo
export START_TIME="Start:  `date +"%Y-%m-%d %H:%M:%S"`"
echo "COMMAND: /perforce/bin/p4 -p $P4PORT -u $P4USER -c $P4CLIENT obliterate -y //$P4CLIENT/..."
/perforce/bin/p4 -p $P4PORT -u $P4USER -c $P4CLIENT obliterate -y //$P4CLIENT/...
export FINISH_TIME="Finish: `date +"%Y-%m-%d %H:%M:%S"`"
echo "Start:  $START_TIME"
echo "Finish: $FINISH_TIME"
echo

echo ++++++++++++++++++++++++++++++++++++++++++++

