# shellcheck shell=bash
# cmd_skip [N] — defer an exercise to the SRS queue.

cmd_skip() {
  local pad
  if [[ "${1:-}" =~ ^[0-9]+$ ]]; then
    pad="$(_pad "$1")"
  elif [[ -f "${CURRENT_FILE}" ]]; then
    pad="$(_pad "$(cat "${CURRENT_FILE}")")"
  else
    pad="$(_pad "$(_current_day)")"
  fi
  _log_append "$(_today)" "${pad}" "skipped"
  _srs_update "${pad}" 0
  printf "%s Day %s skipped — queued for review tomorrow\n" "${IC_CROSS}" "${pad}"
}
