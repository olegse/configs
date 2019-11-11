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
  echo "locations. If no file was specified on the command line, only this files"
  echo "are processed. If the destination file exists, backup is created."
  echo ""
  echo "  -i      install files (default)"
  echo "  -s      update directory with the system config files"
  echo "  -l      list config files in the directory"
  echo "  -h      print this help and exit"

  exit $1
}

test $1 || usage 0;
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

shift $((OPTIND-1))   # now $* is the remained filenames
test "$*" && files=$* || files=$( ls -1 | grep -v "$(basename $0)\|.*.old");

# Perform an action

test $action == l && { echo "$files"; exit 0; };  # list files on 'l'

# Install config files
function i {
  for file in $files
  do 
    cp -v -b $file ~/.$file
  done
}

#  Source system files into the current directory,
#  adding a '.old' suffix for the existent ones.
function s {
  for file in $files
  do
    cp -vbS.old ~/.$file $file
  done

  declare -a modified_files
  for file in $files
  do
    if ! cmp -s $file $file.old
    then
      modified_files[${#modified_files[@]}]=$file
    fi
  done

  if [[ "${modified_files[@]}" ]]
  then
    echo "There is difference in the following files: "
    for file in ${modified_files[@]}
    do echo "   $file <-> $file.old"
    done
    echo "Please review and merge backed up files; they are" \
         "ignored and will not be pushed to repository."
  fi
}

$action
