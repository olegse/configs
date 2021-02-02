# Program aliases

############   VBOX   #####################

alias vbox="VBoxManage"

alias list_runningvms="VBoxManage list runningvms 2>&1 | awk '{ print $1 }'"

function store_vm_uuid() {
  list_runningvms | grep $1
}
# Get running vm uuid by name; [ ] How to use passed name
# as a backreference to variable name?
function get_vm_uuid() {
  # Maybe add a select prompt; will be easier
  if [ $# -eq 0 ]
  then  
    VBoxManage list vms | awk '{print $1}'
  elif [ $# -eq 1 ] && [[ ! $1 =~ help ]]
  then
    vm=$(VBoxManage list vms | sed -n "/^\"$1\"/ s/.*{\(.*\)}.*/\1/p")
    if ! test -n "$vm" 
    then
      echo "vm '$1' was not found"
    else
      echo "vm=$vm"
    fi
  else
    echo "get_vm_uuid [NAME]"
  fi
}


################# TMUX ####################

# Configure container aliases

# Set cnt_id to id of the last container
alias cnt_id='docker ps --no-trunc --latest --quiet'
# Set cnt_ip to ip of the last created container
alias cnt_ip='docker container inspect `cnt_id` -f "{{ .NetworkSettings.IPAddress}}"'
# Show environment of the last container that was created
alias cnt_env='docker exec $(cnt_id) env'
# Open a shell to the last container that was used
alias cnt_open='docker exec -it $(cnt_id) bash'
# Display network information about the last container that was used
alias cnt_netinfo='docker inspect $(cnt_id) -f "{{json .NetworkSettings}}" | grep -o "\(NetworkID\|IPAddress\)[^,]\+" | sed -n "/NetworkID/,/IPAddress/ {s/\":\"/\t/; s/\"//p}"'
#  Display network id of the last container that was used
alias cnt_netid='docker inspect $(cnt_id) -f "{{json .NetworkSettings}}" | grep -o "NetworkID[^,]\+" | cut -d: -f2'
# Remove last container that was used
alias cnt_rm='docker rm -f $(cnt_id)'

#
# User-defined bash functions
#

############   DOCKER   #####################
function compose()  { docker-compose $@; }
function  images()  { docker  images $@; }


# Inspect container
function inspect() {
  test $1 && id=$1 || id=$(cnt_id)
  docker inspect $id | less
}

function netinfo() {
  test $1 && id=$1 || id=$(cnt_id)
  docker inspect ${id} -f "{{json .NetworkSettings}}" | \
    grep -o "\(NetworkID\|IPAddress\)[^,]\+" | \
    sed -n "/NetworkID/,/IPAddress/ {s/\":\"/\t/; s/\"//p}"
}



################   APT   #####################

# Show package description
function apt_show_description() {
  if ! [ $1 ]
  then  echo "apt_show_description PACKAGE"
  else apt show $1 2>/dev/null | sed -n '/^Description/,$p'
  fi
}

# Show fields available in `apt show` output
function apt_show_fields() {
  if ! [ $1 ]
  then echo "apt_show_fields PACKAGE"
  else apt show  $1 2>/dev/null | awk -F: '/^\w/ {print $1}'
  fi
}

# Show specified field  
function apt_show_field() { 
  if [ ${#} -ne 2 ]
  then  echo "apt_show_field PACKAGE FIELD"
  else echo $2; apt show $1 2>/dev/null | sed -n "/$2/,$;ip"
  fi
}

# Show repository sources files
function apt_show_repo() {
  if ! [ "$1" ]
  then  grep "^[^#]*\w" /etc/apt/sources.list{,.d/*} 
  else  grep "^[^#]*\w" /etc/apt/sources.list{,.d/*} | grep -i "$1"
  fi
}


################ User-defined Functions ####################

# Variables  + #

# Openssl alghoritm used by encrypt_file() and decrypt_file() functions
OPENSSL_ENC_ALG=-aes-256-cbc



# Perform an action on a directories in CDPATH
# 
# cdpath        print search directories
# cdpath zip    navigate to the directory in which file "zip" is
#               located
# cdpath vim zip    if passed more than one argument, treat first 
#                   argument as executable and all the others should
#                   searched prior in CDPATH
#
# If file was not found navigate to the directory of the files that mention the pattern
function cdpath() {

  declare -a files
  declare -a found

  #default action
  bin=cd

  if [ "$#" -gt 1 ]   # process found files through executable
  then 
    bin=$1
    shift
    while [[ $1 =~ ^- ]]
    do
      bin=$bin\ $1
      shift
    done
  fi
  action=$bin

  
  for file
  do echo "Processing pattern... '$file'..";

    paths=($(find -L ${CDPATH//:/ } -type f -not -path '*/.*' -and -name ${file} 2> /dev/null ))
        #find ${CDPATH//:/ } -type f -name ${file} 2> /dev/null) 
  
    echo "Found: ${paths[@]} (${#path[@]})"

    case ${#paths[@]} in

      [2-9]|[1-9][0-9]) 

        echo "Found more than one file in a CDPATH"

        PS3="Select files to process or 'all' (action: $action):   "
        select path in ${paths[@]}
        do
          if [ -n "${path}" ]     # selection was made
          then
            paths=( $path ) ; break    # set found[] to one element
          fi

          if [[ $REPLY =~ ^a(ll)?$ ]] || [ -n "${path}" ] 
          then  # if "all" paths[] is not modified 
            break     
          fi
        done    
        ;&
        
      1) 
        # add current files set corresponding to the 'file' pattern to
        # the files[] array
        files+=( ${paths[@]} )
        ;;

      0)
        # no files; nothing to add
        ;;

      *) echo "Something unexpected happened"
        ;;
     esac
  done 

  case $action in
    cd)
      test ${#files[@]} -eq 1 || { echo "Cannot naviagate multiple directories."; \ exit 2; } 
      files=( `dirname $files` )
    ;;
  esac

  # Finally run binary with all the flags
  #echo "${bin} ${files[@]}"
  ${bin} ${files[@]}
}


# Display files in CDPATH, for those who has absolute a relative
# paths specified visualise file existense.
function find_files_in_cdpath() {

  declare -a files
  declare -a paths

  for file
  do #echo "Processing pattern... '$file'..";

    # Search only for those files that are not relative or 
    # full path
    if ! [[ $file =~ \/ ]] 
    then
      paths=( $( find ${CDPATH//:/ } -type f -not -path '*/.*' -and -name ${file} 2> /dev/null ) )
    
      echo "Found: ${paths[@]}"

      case ${#paths[@]} in

        [2-9]|[1-9][0-9]) 

          echo "Found more than one file in a CDPATH"

          PS3="Select files to process or 'all':   "
          select path in ${paths[@]}
          do
            if [ -n "${path}" ]     # selection was made
            then
              paths=( $path ) ; break    # set found[] to one element
            fi

            if [[ $REPLY =~ ^a(ll)?$ ]] || [ -n "${path}" ] 
            then  # if "all" paths[] is not modified 
              break     
            fi
          done    
          ;&
          
        1) 
          # add current files set corresponding to the 'file' pattern to
          # the files[] array
          files+=( ${paths[@]} )
          ;;

        0)
          # no files; nothing to add! add anyway and then run function
          # visualisatino files existence
          ;;

        *) echo "Something unexpected happened"
          ;;
      esac
    #
    # Relative or full path to the file was passed, just add it to the global
    # array
    else
      files+=( file )
    fi
  done 
}

# Open file(s) found in CDPATH. If file was not found 
# create it.
function vim-in-cdpath() {
  
  declare -a files
  declare -a paths

  flags='-p'          # default flag when opening vim
  bin=`type -P vim`   # find path to vim executatble instead
                      # trigerring an alias again

  while [[ $1 =~ ^- ]]
  do
    flags=$flags\ $1
    shift
  done

  for file
  do 
  
    echo "Processing pattern... '$file'..";

    # Search only for those files that are not relative or 
    # full path
    if [[ ! $file =~ \/ && ! -e $file ]] 
    then

      paths=( $( find ${CDPATH//:/ } -type f -not -path '*/.*' -and -name ${file} 2> /dev/null ) )
    
      echo "Found: ${paths[@]}"

      case ${#paths[@]} in

        [2-9]|[1-9][0-9]) 

          #echo "Found more than one file in a CDPATH"

          PS3="Select files to process or 'all':   "
          select path in ${paths[@]}
          do
            if [ -n "${path}" ]     # selection was made
            then
              paths=( $path ) ; break    # set found[] to one element
            fi

            if [[ $REPLY =~ ^a(ll)?$ ]] || [ -n "${path}" ] 
            then  # if "all" paths[] is not modified 
              break     
            fi
          done    

            ;&
          
        1) 
          # add current files set corresponding to the 'file' pattern to
          # the files[] array
          files+=( ${paths[@]} )

            ;;

        0)
          # no files - create new file (simulating vim behavior)
          files+=( $file )

            ;;

        *) echo "Something unexpected happened"

            ;;
      esac
    #
    # Relative or full path to the file was passed, just add it to the global
    # array
    else
      files+=( $file )
    fi
  done 
  #echo ${bin} ${flags} ${files[@]}
  ${bin} ${flags} ${files[@]}
}

# Print "OK" or ":(" 
function mounted() {
  mount | grep -q "$1" && echo "OK" || echo ":("
}

# Search in files for a pattern and display found strings with file
# name. The idea is that function will accept a maxdepth, mindepth or both

function find_in_file() {
  test $1 || { echo "missing search string"; return 1; }
  find . -maxdepth ${2:-1} -type f -exec grep --with-filename "$1" {} \;  # -H
}

# Encrypt file using openssl. Encryption alghoritm is identified by OPENSSL_ENC_ALG.
#  how I was catching an option in args list? Check in Pelmet sources...
function encrypt_file() {
  test $1 || { echo "missing file name"; return 1; }
  #echo "OPENSSL_ENC_ALG: $OPENSSL_ENC_ALG"
  openssl enc $OPENSSL_ENC_ALG -in $1 -out $1.enc

  # After file was encrypted try to unencrypt it and diff with the original
  # if they are the same remove original and temporary decrypted and leave
  # only the encrypted one.
}

# Decrypt files encrypted by encrypt_file(). Expects
# second argumnet to be a directory path where file should 
# be decrypted. If it is not a directory treat it as filename.
# If no argument was supplied the output on stdout.
function decrypt_file() {
  test $1 || { echo "missing file name"; return 1; }
  # print to STDOUT by default
  out=-

  # Change output file with respect to the second argument
  case $2 in
    '.'|*/)
      # If '.' was specified as second argument use same file
      # name but without prefix (i.e. creds.enc -> creds )
      # full path is current directory, $2='.'; if '/' is found
      # at the end it is treated as filename. We must use ${var%<end_pattern>} 
      # construct to strip additional '/' then.
      out=${2%/}/`basename $1 .${1/*.}`;;
    
    ?*)
      echo here
      # Full path, slash will remain
      if [ ${2/[a-z]*} ]
      then
        out=$2
      else
        out=./$2
      fi;;
      
  esac


  in=$1; cp $1{,.bak}
  echo "in: $in"
  echo "out: $out"
  # Test if resulting file names pointing to the same file
  test -e $out && { 
  
    echo -e "Warning! Rewriting an existing file!\nSpecify file" \
         "name explictly by full path or base directory by" \
         "\nprepending slash at the end.";
   return 5;}

  openssl enc -d $OPENSSL_ENC_ALG -in $in -out $out
}

### more libraries ###
if [ -e $HOME/bash/scripts/lib/functions.sh ]; then
source $HOME/bash/scripts/lib/functions.sh; fi
