#!/bin/bash
#
# Distribute config files to their respective places on the filesystem. 

# To implement:
#     Add an option to remove backup files when it is no difference
#     between files or interactive

function usage() {
  echo "Usage: `basename $0 .sh` [-i] [-s] [FILE]..."
  echo ""
  echo "Install config files to their respective system"
  echo "locations. If file names were specified on the command line, only this files"
  echo "are processed. Use -l to see current configuration files.Files can be either "
  echo "distributed or sourced from the system. Sourced files are pushed to repository automatically after sourcing."
  echo ""
  echo "  -i      install files (default)"
  echo "  -s      update directory with the system config files"
  echo "  -l      list config files in the directory"
  echo "  -m      show if it is a difference between new and backed-up configuration file"
  echo "  -f      force pushing even if it is untracked files; configs always taken"
  echo "  -p      source the files from the system and push the code if it is no file difference"
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

if [ -n "$*" ]
then
  files=$*
  files="($( echo "$files" | sed 's/ /|/g' ))"
fi
#echo "$files"
declare -a files=( $( ls -d *  | grep -E $v "${files:-.}" | sed -e 's/ \?install.sh// ' -e 's/ \?\S*.old//g'  ) )
#echo "${files[@]}"
#echo "${files[@]}"
#echo "${files[1]}"
#############################
# Perform an action
#
# List files
test "$action" == l && { 
  for file in  "${files[@]}"
  do 
    echo "$file" 
  done;
  exit 0;
  };  # list files on 'l'

# Push the code if it is no untracked files
function p() {
                  # with exclude standard shows only untracked
  s #ource config files
  
  # Probably source here
  if git ls-files --others --exclude-standard | grep -q .
  then
    echo "Found untracked files... review directory carefully.. aborting..."
    exit 1
  fi
  git add . -A
  git commit -m "Date:  $(date +'%y-%m-%d   %r')"
  git push
}

# Install config files. Copy under current directory.
# Probably need to manage file<->directory reference
function i {
  for file in $files
  do 
    cp -v -b $file ~/.$file # back file will be displayed only if backed up
  done
}

#  Source system files into the current directory,
#  adding a '.old' suffix for the existent ones.
function s {
  for file in ${files[@]}
  do
    echo "Checking for existence for '~/.$file'"
    if [ -e ~/.$file ]
    then 
      cp ~/.$file $file # make backups only when files 
    else
      echo "No config file found on the system for '$file'.. ignoring.."
    fi
  done
}

# Execute action here
${!action}
