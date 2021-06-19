# User-defined functions

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

#--------------------------------------------------------------------------#
# Following is the file encryption and decryption functions by openssl(1)  #
# using alghoritm:
OPENSSL_ENC_ALG=-aes-256-cbc
#
# encrypt_file() using ENC_SUF for the newly created encrypted file.
ENC_SUF=.enc
#--------------------------------------------------------------------------#

# encrypt_file FILE [ENC_FILE]
#               Encrypt file using openssl(1) using OPENSSL_ENC_ALG.
#               The resulting file appended an $ENC_SUF.
function encrypt_file() {
  test $1 || { echo "missing file name"; return 1; }
  file=$1
  newfile=${2:-$1}${ENC_SUF}
  
  if [ $debug -gt 0 ]
  then
    echo "file:      $file"
    echo "newfile:   $newfile"
    return
  fi

  openssl enc $OPENSSL_ENC_ALG -in $file -out $newfile

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

# find(1) wrapper, displays file names in which pattern was found
#  
# Usage: [grep_opts] dir [DIR] [DEPTH] EXPR
#
# Note the options to grep(1). It can be changed by passing another values
# explicitly on the command line.
GREP_OPTS="--color --with-filename --line-number $grep_opts";
function dir () 
{ 
  grep_opts=$GREP_OPTS
  case $# in 
      3)
          dir=$1;
          depth=$2;
          expr=$3
      ;;
      2)
          dir=$1;
          expr=$3
      ;;
      1)
          expr=$1
      ;;
      0)
          echo "search pattern must be specified!" 2>&1;
          return 1
      ;;
  esac;
  find $dir -maxdepth $depth -type f -exec grep ${grep_opts} {} -e "$expr" \;
}
