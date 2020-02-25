#!/bin/bash
#
# Distribute config files to their respective places on the filesystem. 
# existing configs permanently.
# Add an option to learn from existing config into the directory.
# Accept directory prefix.

# To implement:
#     Backup files or `--no-backup' to overwrite.
#     Add an option to remove backup files.
# Expand short option to function name.
# Add a prompt to remove the files.

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
  echo "  -m      show if it is a difference between new and backed-up configuration file"
  echo "  -h      print this help and exit"

  exit $1
}

while getopts "islmh" opt; do
  case $opt in
    i) ;;
    s) ;;
    l) ;;
    m) ;;
    h) usage 0 ;;
    *) usage 1 ;;
  esac
  action=$opt
done
test -n "$action" || usage 1; # no action was specified

shift $((OPTIND-1))   # now $* is the remained filenames
                      # exclude from listing script name and backed-up files
                      # from the previous sourcing procedure
test "$*" && files=$* || files=$( ls -1 | grep -v "$(basename $0)\|.*.old");


# Perform an action
#
# List files
test "$action" == l && { echo "$files"; exit 0; };  # list files on 'l'

# Install config files
function i {
  for file in $files
  do 
    cp -v -b $file ~/.$file # back file will be displayed only if backed up
  done
}

# Show difference between new and backedup file
function m() {
  declare -a modified_files identical_files
  for file in $files
  do
    if test -e "$file.old"
    then
      if ! diff $file $file.old 2>/dev/null
      then
        modified_files[${#modified_files[@]}]=$file
      else
        identical_files[${#identical_files[@]}]=$file
      fi
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
  elif
     [[ -n "${identical_files[@]}" ]]
    then
    echo "No difference was found in the backed files. "
    echo "Following files can be safely removed: "
    for file in ${identical_files[@]}
    do echo "   $file.old"
    done
  else
    if [ "$action" == "s" ]
    then
      echo "No backup files were created."
    else
      echo "No backup files were found."
    fi
  fi
  unset modified_files identical_files
}

#  Source system files into the current directory,
#  adding a '.old' suffix for the existent ones.
function s {
  for file in $files
  do
    cp -vbS.old ~/.$file $file
  done
  m         # show_modified
}

$action
