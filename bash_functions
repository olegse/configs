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


# Perform an action on a directories in CDPATH
# 
# cdpath        print search directories
# cdpath zip    navigate to the directory in which file "zip" is
#               located
# cdpath vim zip    if passed more than one argument, treat first 
#                   argument as executable and all the others should
#                   searched prior in CDPATH
#
function cdpath() {

  declare -a files
  declare -a found

  #default action
  bin=cd
  action=$bin

  if [ "$#" -gt 1 ]   # process found files through executable
  then 
    bin=$1
    action=$bin
    while [[ $1 =~ ^- ]]
    do
      bin=$bin\ $1
      shift
    done
  fi
  
  for file
  do #echo "Processing pattern... '$file'..";

    paths=$( 
        find ${CDPATH//:/ } -type f -not -path '*/.*' -and -name ${file} 2> /dev/null
        ) 
  
    echo "Found: ${paths[@]}"

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
          # no files; nothing to add
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
  bin=`type -P vim`   # find path to vim executatble

  while [[ $1 =~ ^- ]]
  do
    flags=$flags\ $1
    shift
  done

  echo "In vim-in-cdpath"
  for file
  do 
  
    echo "Processing pattern... '$file'..";

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
 echo ${bin} ${flags} ${files[@]}
}
