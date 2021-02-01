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
  { (($#==1)) && [[ -b "$1" ]] && [[ "$(whoami)" = "root" ]]; } || { echo "${FUNCNAME[0]}: error1"; return 1; }
  lsblk -f "$1"
  echo
  local MODEL
  MODEL="$(get_model "$1")" || { echo "${FUNCNAME[0]}: error2"; return 1; }
  read -erp "wipe \"$MODEL\"? "
  echo
  # /usr/bin/time --format="\n  wall clock time - %E\n" badblocks -e 1 -o "/root/$(get_model "$1").txt" -s -v -w "$1"
  /usr/bin/time --format="\n  wall clock time - %E\n" badblocks -o ~darren/archiso/"badblocks_$MODEL.txt" -s -v -w "$1"
}

function main {
  destructive /dev/sda
}

echo
main
