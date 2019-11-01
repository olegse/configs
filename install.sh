#!/bin/bash
#
# Distribute config files to their respective places on the filesystem. 
# existing configs permanently.
# Add an option to learn from existing config into the directory.
# Accept directory prefix.

# To implement:
#     Backup files or `--no-backup' to overwrite.
#     Add an option to remove backup files.

function usage() {
 
  echo "Usage: `basename $0 .sh` [-i] [-s] [FILE]..."
  echo ""
  echo "Install config files. Install files to their respective system"
  echo "locations. If one or more files are specified only this files are"
  echo "processed. If the destination file exists, it is backed up."
  echo ""
  echo "  -i      install files (default)"
  echo "  -s      update directory with the system config files"
  echo "  -l      list config files in the directory"
  echo "  -h      print this help and exit"

  exit $1
}

files=$( ls -1 | grep -v $(basename $0))

while getopts "islh" opt; do
  case $opt in
    i) ;;
    s) ;;
    l) ;;
    h) usage 0 ;;
    *) usage 1 ;;
  esac
  action=$opt
done

function i {
  echo in i; exit
  for file in $files
  do 
    cp -v -b $file ~/.$file
  done
}

# Source system files into the current directory
function s {
  for file in $files
  do
    cp -vbS.old ~/.$file $file
  done
}

# List all the files that gonna be processed
function l {
  ls -1 | grep -v $(basename $0)
}

$action
