# shellcheck shell=bash
# Spaced repetition (SM-2 style, simplified).
# SRS_FILE: tab-separated, one line per queued exercise:
#   PAD <TAB> LAST_DATE <TAB> REPS
# REPS = consecutive correct recalls, capped at 3.
# Interval = SRS_INTERVALS[min(REPS, 3)] days after LAST_DATE.
# Only skipped exercises enter the queue; a correct "done" advances them.

_srs_update() {  # _srs_update PAD CORRECT(1=pass, 0=fail)
  local pad="$1" correct="$2" existing_reps="" reps today tmp
  _ensure_log

  [[ -f "${SRS_FILE}" ]] \
    && existing_reps="$(awk -v p="${pad}" '$1==p{print $3}' "${SRS_FILE}")"

  # A correct recall of an exercise that is not queued has nothing to track.
  if [[ "${correct}" -eq 1 && -z "${existing_reps}" ]]; then
    return 0
  fi

  reps="${existing_reps:-0}"
  if [[ "${correct}" -eq 1 ]]; then
    if [[ "${reps}" -lt 3 ]]; then reps=$(( reps + 1 )); fi
  else
    reps=0
  fi

  today="$(_today)"
  tmp="$(mktemp)"
  if [[ -n "${existing_reps}" && -f "${SRS_FILE}" ]]; then
    awk -v p="${pad}" -v d="${today}" -v r="${reps}" \
      '$1==p{print p"\t"d"\t"r; next} {print}' "${SRS_FILE}" > "${tmp}"
  else
    [[ -f "${SRS_FILE}" ]] && cat "${SRS_FILE}" > "${tmp}"
    printf "%s\t%s\t%s\n" "${pad}" "${today}" "${reps}" >> "${tmp}"
  fi
  mv "${tmp}" "${SRS_FILE}"
}

_srs_due_list() {  # zero-padded exercise numbers due today, oldest first
  [[ -f "${SRS_FILE}" ]] || return 0
  local today pad last_date reps idx interval due_date
  today="$(_today)"
  while IFS=$'\t' read -r pad last_date reps; do
    idx=$(( reps < 4 ? reps : 3 ))
    interval="${SRS_INTERVALS[${idx}]}"
    due_date="$(_date_add "${last_date}" "${interval}")"
    if [[ ! "${due_date}" > "${today}" ]]; then
      printf "%s %s\n" "${pad}" "${due_date}"
    fi
  done < "${SRS_FILE}" | sort -k2 | awk '{print $1}'
  return 0
}

_srs_pending_count() {
  _srs_due_list | grep -c . || true
}
