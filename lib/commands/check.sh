# shellcheck shell=bash
# cmd_check [N] — run the exercise's assertions against live tmux state.

cmd_check() {
  local day pad file title assertions line passed=0 failed=0
  if [[ "${1:-}" =~ ^[0-9]+$ ]]; then
    day="$1"
  else
    day="$(_current_day)"
  fi
  pad="$(_pad "${day}")"
  file="$(_ex_file "${pad}")"
  if [[ ! -f "${file}" ]]; then
    echo "Exercise not found: ${file}" >&2; return 1
  fi

  title="$(_ex_title "${file}")"
  assertions="$(_ex_check_lines "${file}")"
  if [[ -z "${assertions}" ]]; then
    echo "No check defined for: ${title}"
    return 0
  fi

  echo
  echo "Checking: ${title}"
  echo

  while IFS= read -r line; do
    [[ -z "${line}" ]] && continue
    if _run_assertion_line "${line}"; then
      passed=$(( passed + 1 ))
    else
      failed=$(( failed + 1 ))
    fi
  done <<< "${assertions}"

  echo
  if [[ "${failed}" -eq 0 ]]; then
    printf "All %d checks passed ✓\n" "${passed}"
  else
    printf "%d/%d checks passed\n" "${passed}" "$(( passed + failed ))"
    return 1
  fi
}
