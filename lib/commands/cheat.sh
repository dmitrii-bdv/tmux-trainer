# shellcheck shell=bash
# cmd_cheat [--all] — print Ctrl-b shortcuts introduced so far (or all).

cmd_cheat() {
  local max n pad file title shortcuts
  if [[ "${1:-}" == "--all" ]]; then
    max="${TOTAL_EXERCISES}"
  else
    max="$(_current_day)"
  fi

  echo
  printf "=== tmux cheat sheet (days 1–%d) ===\n" "${max}"

  for (( n=1; n<=max; n++ )); do
    pad="$(_pad "${n}")"
    file="$(_ex_file "${pad}")"
    [[ -f "${file}" ]] || continue
    shortcuts="$(_ex_shortcuts "${file}")"
    if [[ -n "${shortcuts}" ]]; then
      title="$(_ex_title "${file}")"
      echo
      echo "${title}"
      echo "${shortcuts}"
    fi
  done

  echo
}
