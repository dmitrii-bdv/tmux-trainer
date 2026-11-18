# shellcheck shell=bash
# cmd_show [DAY] — print an exercise (SRS review first when one is due).

_open_iterm() {  # _open_iterm TEMP_FILE — optional, macOS only
  [[ "${TMUX_TRAINER_OPEN_ITERM:-0}" == "1" ]] || return 0
  [[ -d "/Applications/iTerm.app" ]] || return 0
  osascript \
    -e 'tell application "iTerm"' \
    -e '  activate' \
    -e '  create window with default profile' \
    -e '  tell current session of current window' \
    -e "    write text \"cd '${ROOT_DIR}' && cat '$1'\"" \
    -e '  end tell' \
    -e 'end tell' >/dev/null
}

cmd_show() {
  local day pad exercise temp due_list pending streak title summary
  local srs_review="" reps cur_idx nxt_idx

  if [[ $# -gt 0 ]]; then
    if [[ ! "$1" =~ ^[0-9]+$ ]]; then
      echo "Day must be between 1 and ${TOTAL_EXERCISES}" >&2; return 1
    fi
    day=$(( 10#$1 ))
  else
    due_list="$(_srs_due_list)"
    if [[ -n "${due_list}" ]]; then
      day=$(( 10#$(head -1 <<< "${due_list}") ))
      srs_review=1
    else
      day="$(_current_day)"
    fi
  fi

  if [[ "${day}" -lt 1 || "${day}" -gt "${TOTAL_EXERCISES}" ]]; then
    echo "Day must be between 1 and ${TOTAL_EXERCISES}" >&2; return 1
  fi

  pad="$(_pad "${day}")"
  exercise="$(_ex_file "${pad}")"
  if [[ ! -f "${exercise}" ]]; then
    echo "Exercise not found: ${exercise}" >&2; return 1
  fi

  # Working copy in TEMP_DIR so annotations never dirty the repo.
  # Refreshed only when the source is newer than the copy.
  temp="${TEMP_DIR}/tmux-trainer-day-${pad}.md"
  if [[ ! -f "${temp}" ]] || [[ "${exercise}" -nt "${temp}" ]]; then
    cp "${exercise}" "${temp}"
  fi

  # Record the active exercise so done/skip act on the right one.
  _ensure_log
  echo "${pad}" > "${CURRENT_FILE}"

  if [[ "${pad}" == "${TIMED_DRILL_PAD}" ]]; then
    date +%s > "${LOG_DIR}/time_start"
  fi

  title="$(_ex_title "${exercise}")"
  summary="$(_ex_goal "${exercise}")"
  notify_desktop "${title}" "${summary:+${summary} · }Run: tmux-trainer" "${pad}"
  if [[ -n "${WEBHOOK_URL}" ]]; then
    send_webhook "${title}" "${summary}"
  fi

  echo
  echo "=== tmux trainer ==="
  echo "${title}"
  echo

  streak="$(_streak)"
  pending="$(_srs_pending_count)"

  if [[ "${pending}" -gt 10 ]]; then
    printf "%s %d reviews due — consider a catch-up session first.\n" \
      "${IC_WARN}" "${pending}"
    echo
  fi

  if [[ -n "${srs_review}" ]]; then
    reps="$(awk -v p="${pad}" '$1==p{print $3}' "${SRS_FILE}" 2>/dev/null)"
    reps="${reps:-0}"
    cur_idx=$(( reps < 3 ? reps : 3 ))
    nxt_idx=$(( reps < 3 ? reps + 1 : 3 ))
    printf "%s SRS review (%d due)  ·  interval %dd -> %dd on pass\n" \
      "${IC_BOOKS}" "${pending}" "${SRS_INTERVALS[${cur_idx}]}" \
      "${SRS_INTERVALS[${nxt_idx}]}"
  elif [[ "${pending}" -gt 0 ]]; then
    printf "%s %d review(s) due — run \`tmux-trainer\` after this one\n" \
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

  echo
  cat "${temp}"
  echo

  printf "  → annotate freely: %s\n" "${temp}"
  if [[ "$(_today_status "${pad}")" != "completed" ]]; then
    if [[ -n "${srs_review}" ]]; then
      echo "  → \`tmux-trainer done\` to pass  ·  \`tmux-trainer skip\` to re-queue"
    else
      echo "  → \`tmux-trainer done\` when finished  ·  \`tmux-trainer skip\` to queue for later"
    fi
  fi
  echo

  _open_iterm "${temp}"
  return 0
}
