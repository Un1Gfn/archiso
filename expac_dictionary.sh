#!/bin/bash

trap 'echo' EXIT

function dict {
  (( $#>=1 )) || { echo "${FUNCNAME[0]}: error"; return 1; }
  expac --sync '%n\t%d' "$@" | column --separator $'\t' --table
  echo
}

echo
(($#>=1)) && dict "$@"

while :; do
  read -e -p "search: " -r line
  echo
  # shellcheck disable=SC2086
  dict $line
done
