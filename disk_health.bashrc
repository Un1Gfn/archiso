#!/dev/null
# Must be sourced instead of executed

function smart {

  # https://wiki.archlinux.org/index.php/S.M.A.R.T.
  smartctl --info /dev/sda | grep 'SMART support is:'

  smartctl --capabilities /dev/sda

  # /usr/bin/time --format="\n  wall clock time - %E\n"
  smartctl --test=short /dev/sda
  smartctl --test=long /dev/sda

  smartctl --health /dev/sda
}

function get_model {
  { (($#==1)) && [[ -b "$1" ]] && [[ "$(whoami)" = "root" ]]; } || { echo "${FUNCNAME[0]}: error"; return 1; }
  # hdparm -I /dev/sda | grep 'Model Number:' | tr " \t" "*&"
  hdparm -I /dev/sda | pcregrep -o1 "^\tModel Number:       (.*)" | sed 's/ *$//g' | tr " \t" "_-"
}

function destructive {
  {
    [[ "$(whoami)" = "root" ]] && [[ -b "$1" ]] && {
        (($#==1)) ||
      { (($#==2)) && [[ "$2" =~ ^[0-9]+$ ]] && [[ "$2" -ge 1 ]]; }
    }
  } || {
    echo "${FUNCNAME[0]}: error1"
    return 1
  }
  lsblk -f "$1"
  echo
  local MODEL
  MODEL="$(get_model "$1")" || { echo "${FUNCNAME[0]}: error2"; return 1; }
  read -erp "wipe \"$MODEL\"? "
  echo
  # -e 1
  /usr/bin/time --format="\n  wall clock time - %E\n" badblocks \
    -b 1024 \
    -o ~darren/archiso/"badblocks_$MODEL.txt" \
    -s \
    -v \
    -w \
  "$1" "$2"
}

# Approx. 60Gi
function hitachi {
  destructive /dev/sda
}

# Approx. 500Gi
# Test the first 100Gi only
function toshiba {
  local BLK_SZ=$((1024))
  local Ki=$((1024))
  local Mi=$((1024*Ki))
  local Gi=$((1024*Mi))
  local number_of_blocks_in_100Gi=$((100*Gi/BLK_SZ))
  echo "$number_of_blocks_in_100Gi"
  destructive /dev/sda "$number_of_blocks_in_100Gi"
}

echo

toshiba
