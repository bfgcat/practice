#!/bin/sh

echo Start

P4PORT=$1
P4USER=$2
P4CLIENT=$3

export P4PORT=$P4PORT
export P4USER=$P4USER
export P4CLIENT=$P4CLIENT
export LOGFILE="/perforce/log/Oblit.log"
export OBLIT_SCRIPT="/perforce/scripts/scheduled_oblit.sh"

$OBLIT_SCRIPT $P4PORT $P4USER $P4CLIENT 2>&1 | tee -a $LOGFILE

echo Done

