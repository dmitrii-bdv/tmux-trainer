# shellcheck shell=bash
# Exercise catalog: discovery and parsing of exercises/day-NN.md files.
# Each exercise has a "# Title" heading, a "Goal:" line, a "tags:" line,
# and an optional "## Check" section with a ```text block of assertions.

TOTAL_EXERCISES=$(find "${EXERCISE_DIR}" -maxdepth 1 -name 'day-*.md' | wc -l | tr -d ' ')

_pad() { printf "%02d" "$(( 10#$1 ))"; }          # 7 or 07 -> 07
_ex_file() { echo "${EXERCISE_DIR}/day-$(_pad "$1").md"; }

_ex_title() { grep -m1 '^# ' "$1" | sed 's/^# //'; }
_ex_goal()  { grep -m1 '^Goal:' "$1" | sed 's/^Goal:[[:space:]]*//'; }
_ex_tags()  { grep -m1 '^tags:' "$1" | sed 's/^tags:[[:space:]]*//'; }

_ex_has_tag() {  # _ex_has_tag FILE TAG
  local tags t
  tags="$(_ex_tags "$1")"
  for t in ${tags//,/ }; do
    [[ "${t}" == "$2" ]] && return 0
  done
  return 1
}

_ex_check_lines() {  # assertion lines from the ```text block in ## Check
  awk '
    /^## Check$/    { sec=1; next }
    /^## /          { sec=0; blk=0; next }
    sec && /^```text/ { blk=1; next }
    sec && /^```/   { blk=0; next }
    sec && blk && NF { print }
  ' "$1"
}

_ex_shortcuts() {  # Ctrl-b lines from ```text blocks
  awk '
    /^```text/ { in_block=1; next }
    /^```/     { in_block=0; next }
    in_block && /^Ctrl-b/ { print "  " $0 }
  ' "$1"
}

_existing_pads() {  # zero-padded numbers of exercises that exist
  local n p
  for (( n=1; n<=TOTAL_EXERCISES; n++ )); do
    p="$(_pad "${n}")"
    [[ -f "$(_ex_file "${p}")" ]] && echo "${p}"
  done
  return 0
}

_all_tags() {  # unique tags across all exercises, one per line
  local pad tag
  while IFS= read -r pad; do
    # shellcheck disable=SC2020  # word-splitting on commas and spaces is intended
    for tag in $(_ex_tags "$(_ex_file "${pad}")" | tr ', ' '  '); do
      echo "${tag}"
    done
  done < <(_existing_pads) | sort -u
}

_current_day() {  # exercise for today: 5 per week, weekends map to Monday
  local week dow
  week=$(( 10#$(_week_today) ))
  dow="$(_dow_today)"
  [[ "${dow}" -gt 5 ]] && dow=1
  echo $(( ( (week - 1) * 5 + dow - 1 ) % TOTAL_EXERCISES + 1 ))
}
