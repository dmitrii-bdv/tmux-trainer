# shellcheck shell=bash
# cmd_lint — validate every exercise file. Exit 1 if any problem is found.
# Checks: numbering is contiguous, required headers exist, tags are set,
# and every assertion in the ## Check block is well-formed.

cmd_lint() {
  local errors=0 n pad file line err count
  count=0
  for (( n=1; n<=TOTAL_EXERCISES; n++ )); do
    pad="$(_pad "${n}")"
    file="$(_ex_file "${pad}")"
    count=$(( count + 1 ))
    if [[ ! -f "${file}" ]]; then
      echo "${file}: missing (exercise numbering must be contiguous)"
      errors=$(( errors + 1 )); continue
    fi
    if ! head -1 "${file}" | grep -q '^# '; then
      echo "${file}: first line must be a '# Title' heading"
      errors=$(( errors + 1 ))
    fi
    if ! grep -q '^Goal: ' "${file}"; then
      echo "${file}: missing 'Goal:' line"
      errors=$(( errors + 1 ))
    fi
    if [[ -z "$(_ex_tags "${file}")" ]]; then
      echo "${file}: missing 'tags:' line"
      errors=$(( errors + 1 ))
    fi
    while IFS= read -r line; do
      [[ -z "${line}" ]] && continue
      if ! err="$(_validate_assertion_line "${line}")"; then
        echo "${file}: ${err}  [${line}]"
        errors=$(( errors + 1 ))
      fi
    done < <(_ex_check_lines "${file}")
  done

  # Files on disk beyond the numbering range are also an error.
  for file in "${EXERCISE_DIR}"/day-*.md; do
    [[ -f "${file}" ]] || continue
    n=$(( 10#$(basename "${file}" .md | sed 's/^day-//') ))
    if [[ "${n}" -gt "${TOTAL_EXERCISES}" ]]; then
      echo "${file}: exercise number ${n} is outside 1..${TOTAL_EXERCISES}"
      errors=$(( errors + 1 ))
    fi
  done

  if [[ "${errors}" -eq 0 ]]; then
    echo "OK: ${TOTAL_EXERCISES} exercises valid"
    return 0
  fi
  echo "${errors} problem(s) found" >&2
  return 1
}
