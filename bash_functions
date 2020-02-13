# Program aliases

############   VBOX   #####################

alias vbox="VBoxManage"

# List vms
function list_vms() {
  vm=.*
  test -z "$1" || vm=$1
  #echo "vm: $vm"
  VBoxManage list vms 2>&1 | awk '/'"$vm"'/ { print $1 }'
}

# List only running vm's
function list_runningvms() {
  vm=.*
  test -z "$1" || vm=$1
  #echo "vm: $vm"
  VBoxManage list runningvms 2>&1 | awk '/'"$vm"'/ { print $1 }'
}

# List vms
function list_vms_by_uuid() {
  vm=.*
  test -z "$1" || vm=$1
  #echo "vm: $vm"
  VBoxManage list vms 2>&1 | sed -n "/^\"$vm\"/ s/.*{\(.*\)}.*/\1/p"
}
# ! try to avoid usage of vm and use something like ${1:-.*} 


# Get running vm uuid by name; [ ] How to use passed name
# as a backreference to variable name?
function get_vm_uuid() {
  # Maybe add a select prompt; will be easier
  if [ $# -eq 0 ]
  then  
    list_vms "$1"
  elif [ $# -eq 1 ] && [[ ! $1 =~ help ]]
  then
    vm=$(list_vms_by_uuid "$1")
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
