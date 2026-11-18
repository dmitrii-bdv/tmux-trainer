# shellcheck shell=bash
# cmd_done — mark the active exercise completed (no-op if already done today).

_timed_drill_report() {  # reports elapsed time for the timed exercise
  [[ -f "${LOG_DIR}/time_start" ]] || return 0
  local start elapsed mins secs over
  start="$(cat "${LOG_DIR}/time_start")"
  elapsed=$(( $(date +%s) - start ))
  rm -f "${LOG_DIR}/time_start"
  mins=$(( elapsed / 60 ))
  secs=$(( elapsed % 60 ))
  if [[ "${elapsed}" -le 300 ]]; then
    printf "%s Completed in %dm %02ds  (target: < 5m)\n" \
      "${IC_TIMER}" "${mins}" "${secs}"
  else
    over=$(( elapsed - 300 ))
    printf "%s Completed in %dm %02ds  (target: < 5m — over by %ds)\n" \
      "${IC_TIMER}" "${mins}" "${secs}" "${over}"
  fi
}

cmd_done() {
  local pad streak pending
  if [[ -f "${CURRENT_FILE}" ]]; then
    pad="$(_pad "$(cat "${CURRENT_FILE}")")"
  else
    pad="$(_pad "$(_current_day)")"
  fi

  if [[ "$(_today_status "${pad}")" == "completed" ]]; then
    echo "Day ${pad} already marked done today."
    return 0
  fi

  _log_append "$(_today)" "${pad}" "completed"
  _srs_update "${pad}" 1
  streak="$(_streak)"
  printf "%s Day %s marked as completed\n" "${IC_CHECK}" "${pad}"

  if [[ "${pad}" == "${TIMED_DRILL_PAD}" ]]; then
    _timed_drill_report
  fi

  pending="$(_srs_pending_count)"
  if [[ "${pending}" -gt 0 ]]; then
    printf "%s %d review(s) still due — run \`tmux-trainer\` to continue\n" \
      "${IC_BOOKS}" "${pending}"
  fi
  if [[ "${streak}" -gt 0 ]]; then
    if [[ "${NARROW}" -eq 1 ]]; then
      printf "%s %d-day streak\n" "${IC_FIRE}" "${streak}"
    else
      printf "%s %d-day streak  ·  %s\n" "${IC_FIRE}" "${streak}" "$(_week_bar)"
    fi
  elif [[ "${NARROW}" -eq 0 ]]; then
    _week_bar; echo
  fi
  _check_badges
  return 0
}
