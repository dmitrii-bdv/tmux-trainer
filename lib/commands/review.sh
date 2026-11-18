# shellcheck shell=bash
# cmd_review — open a random completed exercise as an unscheduled drill.

cmd_review() {
  local -a completed=()
  local pad pick
  while IFS= read -r pad; do
    [[ -n "${pad}" ]] && completed+=("${pad}")
  done < <(_completed_pads)

  if [[ ${#completed[@]} -eq 0 ]]; then
    echo "No completed exercises yet — finish one first." >&2
    return 0
  fi

  pick="${completed[$(( RANDOM % ${#completed[@]} ))]}"
  printf "%s Random drill: Day %s\n\n" "${IC_DICE}" "${pick}"
  cmd_show "$(( 10#${pick} ))"
}
