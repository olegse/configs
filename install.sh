#!/bin/bash
#
# Distribute config files to their respective places on the filesystem. 

# To implement:
#     Backup files or `--no-backup' to overwrite.
#     Add an option to remove backup files when it is no difference
#     between files or interactive
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


i=i
s=s
l=l
m=show_diff
p=p
while getopts "islmph" opt; do
  case $opt in
    i) ;;
    s) ;;
    l) ;;
    m) ;;
    p) ;;
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

# ?
function p() {
                  # with exclude standard shows only untracked
  if git ls-files --others --exclude-standard | grep -q .
  then
    echo "Found untracked files... aborting..."
    exit 1
  fi
  git add . -A
  git commit -m "Date:  $(date +'%y-%m-%d   %r')"
  git push
}

# Install config files
function i {
  for file in $files
  do 
    cp -v -b $file ~/.$file # back file will be displayed only if backed up
  done
}

# Show difference between new and backed up file
function show_diff() {
  declare -a modified_files
  
  if -z "$files"
  then
    echo "No backup files were found."
    return
  fi

  for file in $files
  do
    if test -e "$file.old"
    then
      echo "Comparing $file.old..."
      if ! diff $file $file.old 2>/dev/null
      then
        modified_files[${#modified_files[@]}]=$file
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
  else
      echo "All the files are identical."
  fi
}

#  Source system files into the current directory,
#  adding a '.old' suffix for the existent ones.
function s {
  for file in $files
  do
    cp -vbS.old ~/.$file $file
  done
  show_diff         # show_modified
}

# Execute action here
${!action}
