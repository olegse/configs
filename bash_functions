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