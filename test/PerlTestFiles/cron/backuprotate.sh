#!/bin/bash

###########################################
### backuprotate.sh			###
### Delete aging backup files.		###
### A. Caravello 3/18/2010		###
###########################################
# Number of Days to Keep Logs For
KEEPDAYS=5

# Location of Backups
BACKUPS=/perforce/backup

# Loop Through Aging Files
for file in `/usr/bin/find $BACKUPS -type f -name "*.gz" -mtime +$KEEPDAYS -print`
do
	# Display File Being Deleted
	/bin/echo $file

	# Remove File
	/bin/rm -f $file
done
