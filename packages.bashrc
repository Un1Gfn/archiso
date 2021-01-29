#!/dev/null
# Must be sourced instead of executed

# comm -3 <(echo -n "$RELENG") <(echo -n "$UNQ") | column --output-separator '|' --separator $'\t' --table

function coloron {
  (( $#==1 && 30<=$1 && $1<=37 )) || { echo "${FUNCNAME[0]}: error"; return 1; }
  echo -ne "\033[$1m"
}

function coloroff {
  (( $#==0 )) || { echo "${FUNCNAME[0]}: error"; return 1; }
  echo -ne "\033[0m"
}

function colorecho {
  (( $#==2 && 30<=$1 && $1<=37 )) || { echo "${FUNCNAME[0]}: error"; return 1; }
  echo -ne "\033[$1m"
  echo -n  "$2"
  echo -ne "\033[0m"
}

function prepare {
  echo -n "Have you updated package db and file db? "
  read -r
  echo
}

function str_superset {
  # echo -n "###"
  # comm -3 -1 <(echo "$1") <(echo "$2")
  # echo "###"
  { 
    (($#==2)) &&
    [ -z "$(comm -3 -1 <(echo "$1") <(echo "$2"))" ] 
  } || { echo "${FUNCNAME[0]}: error"; return 1; }
}

function str_minus {
  comm -3 -2 <(echo "$1") <(echo "$2")
}

function str_end_with_newline_sorted {
  {
    (($#==1)) &&
    [ "$(tail -c1 <<<"$1" | wc -l)" -eq 1 ] && # https://stackoverflow.com/a/25749716
    [ "$(sort <<<"$1")" = "$1" ]
  } || { echo "${FUNCNAME[0]}: error"; return 1; }
}

function parse_conf {

  { (($#==1)) && [ -f "$1" ]; } || { echo "${FUNCNAME[0]}: error 0"; return 1; }

  # local WHITESPACE_TO_NEWLINE='s|\s\+|\n|g'
  # sed --expression="$STRIP_COMMENTS" --expression="$WHITESPACE_TO_NEWLINE" packages.conf

  # https://stackoverflow.com/a/45409823
  local -r STRIP_COMMENTS='s/#.*$/ /g'
  local -r DUP="$(sed --expression="$STRIP_COMMENTS" "$1" | xargs printf "%s\n" | sort)"
  local -r UNQ="$(uniq <<<"$DUP")"

  # Show duplicates in packages.conf
  str_superset "$DUP" "$UNQ" || { echo "${FUNCNAME[0]}: error 1"; return 1; }
  coloron 37
  echo "duplicates stripped from $1:"
  str_minus "$DUP" "$UNQ" | xargs printf "%s "
  coloroff
  echo
  echo

  local -r BASELINE0="/usr/share/archiso/configs/baseline/packages.x86_64"
  local -r BASELINE="$(grep -v '#' "$BASELINE0")"
  local -r RELENG0="/usr/share/archiso/configs/releng/packages.x86_64"
  local -r RELENG="$(grep -v '#' "$RELENG0")"
  { 
    str_end_with_newline_sorted "$BASELINE" && 
    str_end_with_newline_sorted "$RELENG" &&
    str_end_with_newline_sorted "$UNQ"
  } || { echo "${FUNCNAME[0]}: error 2"; return 1; }

  str_superset "$RELENG" "$BASELINE" || { echo "${FUNCNAME[0]}: error 3"; return 1; }

  # coloron 33
  echo "removed from $RELENG0:"
  str_minus "$RELENG" "$UNQ"
  # coloroff
  echo

  echo "added:"
  str_minus "$UNQ" "$RELENG"
  echo

  echo -n "Checking if all packages exist ... "
  # shellcheck disable=SC2086
  pacman -Si $UNQ 1>/dev/null || { echo "${FUNCNAME[0]}: error 5"; return 1; }
  colorecho 32 "ok"
  echo

}

# https://stackoverflow.com/a/9715377
# A="lorem"
# setvar A
# function setvar {
#   test "$#" -ne 1 && return 1
#   local safevariable="ipsum"
#   eval "$1"=\$safevariable
#   return 0
# }

echo
{ 
  # prepare &&
  parse_conf packages.conf &&
  echo
}
echo
