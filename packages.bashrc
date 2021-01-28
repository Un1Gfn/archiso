#!/dev/null
# Must be sourced instead of executed

function prepare {
  echo -n "Have you updated package db and file db? "
  read -r
  echo
}

function parse_conf {

  # local WHITESPACE_TO_NEWLINE='s|\s\+|\n|g'
  # sed --expression="$STRIP_COMMENTS" --expression="$WHITESPACE_TO_NEWLINE" packages.conf

  # https://stackoverflow.com/a/45409823
  local -r STRIP_COMMENTS='s/#.*$/ /g'
  local -r DUP="$(sed --expression="$STRIP_COMMENTS" packages.conf | xargs printf "%s\n" | sort)"
  local -r UNQ="$(uniq <<<"$DUP")"

  test -n "$(comm -13 <(echo "$DUP") <(sort <<<"$UNQ"))" && { echo "${FUNCNAME[0]}: error"; return 1; }
  echo "Removed duplicate packages:"
  comm -23 <(echo "$DUP") <(sort <<<"$UNQ")
  echo

  echo -n "Checking if all packages exist ... "
  # shellcheck disable=SC2086
  pacman -Si $UNQ 1>/dev/null || { echo "${FUNCNAME[0]}: error"; return 1; }
  echo "ok"
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

# echo
# prepare
# parse_conf
