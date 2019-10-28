#!/bin/bash
#
# Copy config files. Create a backup files or `--no-backup' to overwrite
# existing configs permanently.

# Accept directory prefix
for file in `ls -1 | grep -v $(basename $0)` 
do 
	cp -v -b $file ~/.$file
done
