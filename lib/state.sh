# shellcheck shell=bash
# Progress state: completion log, streaks, weekly bar, milestone badges.
# Log format, one entry per line: "YYYY-MM-DD PAD completed|skipped"
# and "YYYY-MM-DD badge NAME" for milestones.

_ensure_log() { mkdir -p "${LOG_DIR}"; }

_log_append() {  # _log_append DATE FIELD STATUS
  _ensure_log
  echo "$1 $2 $3" >> "${LOG_FILE}"
}

_active_pad() {  # exercise opened last, zero-padded (empty if none)
  [[ -f "${CURRENT_FILE}" ]] && cat "${CURRENT_FILE}" || true
}

_today_status() {  # _today_status [PAD] -> completed|skipped|none
  local pad="${1:-}" last pattern
  [[ -f "${LOG_FILE}" ]] || { echo "none"; return; }
  if [[ -n "${pad}" ]]; then
    pattern="^$(_today) ${pad} "
  else
    pattern="^$(_today) "
  fi
  last="$(grep "${pattern}" "${LOG_FILE}" | tail -1)" || true
  if   [[ "${last}" == *"completed"* ]]; then echo "completed"
  elif [[ "${last}" == *"skipped"*   ]]; then echo "skipped"
  else                                         echo "none"
  fi
}

_completed_on() {  # _completed_on DATE -> exit 0 if any completion that day
  [[ -f "${LOG_FILE}" ]] && grep -q "^$1 .* completed$" "${LOG_FILE}"
}

_streak() {  # consecutive weekdays completed, counting back from today
  [[ -f "${LOG_FILE}" ]] || { echo 0; return; }
  local streak=0 check dow i
  check="$(_today)"
  for (( i=0; i<200; i++ )); do
    dow="$(_date_dow "${check}")"
    if [[ "${dow}" -le 5 ]]; then
      if _completed_on "${check}"; then
        streak=$(( streak + 1 ))
      else
        break
      fi
    fi
    check="$(_date_sub "${check}" 1)"
  done
  echo "${streak}"
}

_week_anchor() {  # prints: ANCHOR DAYS_TO_SHOW (weekend -> last Friday)
  local anchor dow_now days_to_show
  anchor="$(_today)"
  dow_now="$(_dow_today)"
  if [[ "${dow_now}" -gt 5 ]]; then
    anchor="$(_date_sub "${anchor}" $(( dow_now - 5 )))"
    days_to_show=5
  else
    days_to_show="${dow_now}"
  fi
  echo "${anchor} ${days_to_show}"
}

_week_completed_count() {
  local anchor days_to_show d days_back check_date completed=0
  read -r anchor days_to_show <<< "$(_week_anchor)"
  for (( d=1; d<=days_to_show; d++ )); do
    days_back=$(( days_to_show - d ))
    if [[ "${days_back}" -eq 0 ]]; then
      check_date="${anchor}"
    else
      check_date="$(_date_sub "${anchor}" "${days_back}")"
    fi
    if _completed_on "${check_date}"; then
      completed=$(( completed + 1 ))
    fi
  done
  echo "${completed}"
}

_week_bar() {
  local completed i bar=""
  completed="$(_week_completed_count)"
  for (( i=1; i<=5; i++ )); do
    if [[ $i -le $completed ]]; then bar+="█"; else bar+="░"; fi
  done
  printf "[%s] %d/5 this week" "${bar}" "${completed}"
}

_has_badge() { [[ -f "${LOG_FILE}" ]] && grep -q " badge $1$" "${LOG_FILE}"; }

_check_badges() {
  local n p all_done
  if ! _has_badge first-done; then
    _log_append "$(_today)" "badge" "first-done"
    printf "%s Badge unlocked: First completion\n" "${IC_BADGE}"
  fi

  if ! _has_badge first-week && [[ "$(_week_completed_count)" -ge 5 ]]; then
    _log_append "$(_today)" "badge" "first-week"
    printf "%s Badge unlocked: First full week\n" "${IC_BADGE}"
  fi

  if ! _has_badge first-cycle; then
    all_done=1
    for (( n=1; n<=TOTAL_EXERCISES; n++ )); do
      p="$(_pad "${n}")"
      if ! grep -q "^.* ${p} completed$" "${LOG_FILE}" 2>/dev/null; then
        all_done=0; break
      fi
    done
    if [[ "${all_done}" -eq 1 ]]; then
      _log_append "$(_today)" "badge" "first-cycle"
      printf "%s Badge unlocked: First full cycle — all %d exercises done!\n" \
        "${IC_BADGE}" "${TOTAL_EXERCISES}"
    fi
  fi
  return 0
}

_completed_pads() {  # unique zero-padded exercises ever completed
  [[ -f "${LOG_FILE}" ]] || return 0
  awk '/completed$/ {print $2}' "${LOG_FILE}" | sort -u
}
