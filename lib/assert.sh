# shellcheck shell=bash
# Assertion engine for "check". Each exercise lists assertions as lines:
#   TYPE ARG...        arguments may be quoted with "..." or '...'
# Supported types and argument counts are defined in _assert_arity.

_assert_arity() {  # prints the expected argument count, or -1 if unknown
  case "$1" in
    session_exists|file_exists)                        echo 1 ;;
    window_count|window_named|pane_count|pane_running|\
    option_set|pane_contains|file_contains)            echo 2 ;;
    *)                                                 echo -1 ;;
  esac
}

_split_args() {  # _split_args LINE -> fills global array ARGS
  local line="$1" token="" in_tok=0 quote="" c i
  ARGS=()
  for (( i=0; i<${#line}; i++ )); do
    c="${line:i:1}"
    if [[ -n "${quote}" ]]; then
      if [[ "${c}" == "${quote}" ]]; then quote=""; else token+="${c}"; fi
    elif [[ "${c}" == '"' || "${c}" == "'" ]]; then
      quote="${c}"; in_tok=1
    elif [[ "${c}" == " " || "${c}" == $'\t' ]]; then
      if (( in_tok )); then ARGS+=("${token}"); token=""; in_tok=0; fi
    else
      token+="${c}"; in_tok=1
    fi
  done
  if (( in_tok )); then ARGS+=("${token}"); fi
  return 0
}

_validate_assertion_line() {  # prints an error and returns 1 if invalid
  _split_args "$1"
  local want given
  if [[ ${#ARGS[@]} -eq 0 ]]; then
    echo "empty assertion"; return 1
  fi
  want="$(_assert_arity "${ARGS[0]}")"
  given=$(( ${#ARGS[@]} - 1 ))
  if [[ "${want}" -lt 0 ]]; then
    echo "unknown assertion type: ${ARGS[0]}"; return 1
  fi
  if [[ "${given}" -ne "${want}" ]]; then
    echo "${ARGS[0]} expects ${want} argument(s), got ${given}"; return 1
  fi
  return 0
}

_assert() {  # _assert TYPE ARG1 [ARG2] — prints a result line
  local type="${1:-}" a1="${2:-}" a2="${3:-}" pass=0 msg="" actual path content
  case "${type}" in
    session_exists)
      if tmux list-sessions -F '#{session_name}' 2>/dev/null | grep -qx "${a1}"; then
        pass=1; msg="session '${a1}' exists"
      else
        msg="session '${a1}' not found"
      fi
      ;;
    window_count)
      actual="$(tmux list-windows -t "${a1}" 2>/dev/null | wc -l | tr -d ' ')" || actual=0
      if [[ "${actual}" -eq "${a2}" ]]; then
        pass=1; msg="'${a1}' has ${actual} window(s)"
      else
        msg="'${a1}' has ${actual} window(s), expected ${a2}"
      fi
      ;;
    window_named)
      if tmux list-windows -t "${a1}" -F '#{window_name}' 2>/dev/null | grep -qx "${a2}"; then
        pass=1; msg="window '${a2}' found in '${a1}'"
      else
        msg="window '${a2}' not found in '${a1}'"
      fi
      ;;
    pane_count)
      actual="$(tmux list-panes -t "${a1}" 2>/dev/null | wc -l | tr -d ' ')" || actual=0
      if [[ "${actual}" -eq "${a2}" ]]; then
        pass=1; msg="'${a1}' has ${actual} pane(s)"
      else
        msg="'${a1}' has ${actual} pane(s), expected ${a2}"
      fi
      ;;
    pane_running)
      actual="$(tmux display-message -p -t "${a1}" '#{pane_current_command}' 2>/dev/null)" \
        || actual=""
      if [[ "${actual}" == "${a2}" ]]; then
        pass=1; msg="'${a1}' is running '${a2}'"
      else
        msg="'${a1}' running '${actual}', expected '${a2}'"
      fi
      ;;
    option_set)
      actual="$(tmux show-options -gv "${a1}" 2>/dev/null)" || actual=""
      if [[ "${actual}" == "${a2}" ]]; then
        pass=1; msg="${a1} = ${a2}"
      else
        msg="${a1} = '${actual}', expected '${a2}'"
      fi
      ;;
    file_exists)
      path="${a1/#\~/${HOME}}"
      if [[ -f "${path}" ]]; then
        pass=1; msg="file exists: ${path}"
      else
        msg="file not found: ${path}"
      fi
      ;;
    pane_contains)
      content="$(tmux capture-pane -t "${a1}" -p -S - 2>/dev/null)" || content=""
      if grep -qF -- "${a2}" <<< "${content}"; then
        pass=1; msg="'${a1}' contains '${a2}'"
      else
        msg="'${a1}' does not contain '${a2}'"
      fi
      ;;
    file_contains)
      path="${a1/#\~/${HOME}}"
      if [[ -f "${path}" ]] && grep -qF -- "${a2}" "${path}"; then
        pass=1; msg="'${path}' contains '${a2}'"
      else
        msg="'${path}' does not contain '${a2}'"
      fi
      ;;
    *)
      msg="unknown assertion type: ${type}"
      ;;
  esac

  if [[ "${pass}" -eq 1 ]]; then
    printf "  %s %s\n" "${IC_CHECK}" "${msg}"
  else
    printf "  %s %s\n" "${IC_CROSS}" "${msg}"
    return 1
  fi
}

_run_assertion_line() {  # validate, split, and run one assertion line
  local err
  if ! err="$(_validate_assertion_line "$1")"; then
    printf "  %s %s\n" "${IC_CROSS}" "${err}"
    return 1
  fi
  _split_args "$1"
  _assert "${ARGS[@]}"
}
