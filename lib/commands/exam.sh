# shellcheck shell=bash
# Exam mode: a timed, mixed drill over completed exercises.
#   tmux-trainer exam [MINUTES]   start (default 20), inside tmux
#   tmux-trainer exam finish      score the running exam now
#   tmux-trainer exam --timer     internal: countdown pane
# Exercises are picked least-used first, so every exercise gets its turn.
# Running exam state: "START_EPOCH DURATION_SECONDS PAD,PAD,..." in
# ${LOG_DIR}/exam. Each exam is logged as "exam-set" and "exam-result".

_exam_file() { echo "${LOG_DIR}/exam"; }
_exam_results_file() { echo "${TEMP_DIR}/tmux-trainer-exam-results.txt"; }
_exam_sheet_file() { echo "${TEMP_DIR}/tmux-trainer-exam.md"; }

_exam_pick() {  # prints up to EXAM_SIZE pads, least-used first, random ties
  local pad n_used counts="" ranked
  if [[ -f "${LOG_FILE}" ]]; then
    counts="$(awk '$2 == "exam-set" {
      n = split($3, a, ",")
      for (i = 1; i <= n; i++) uses[a[i]]++
    } END { for (k in uses) print k, uses[k] }' "${LOG_FILE}")"
  fi
  ranked="$(while IFS= read -r pad; do
    [[ -z "${pad}" ]] && continue
    n_used="$(awk -v p="${pad}" '$1 == p {print $2}' <<< "${counts}")"
    printf "%s %05d %s\n" "${n_used:-0}" "${RANDOM}" "${pad}"
  done < <(_completed_pads) | sort -k1,1n -k2,2n)"
  [[ -z "${ranked}" ]] && return 0
  head -n "${EXAM_SIZE}" <<< "${ranked}" | awk '{print $3}'
}

_ex_task_text() {  # prints the ## Task section of an exercise file
  awk '/^## Task$/ { f = 1; next } /^## / { f = 0 } f' "$1"
}

_exam_start() {  # _exam_start MINUTES
  local minutes="$1" pads csv sheet pad file quoted_root
  if [[ -z "${TMUX:-}" ]]; then
    echo "Exam mode runs inside tmux. Start a session first: tmux new -s exam" >&2
    return 1
  fi
  if [[ -f "$(_exam_file)" ]]; then
    echo "An exam is already running. Finish it with: tmux-trainer exam finish" >&2
    return 1
  fi
  pads="$(_exam_pick)"
  if [[ -z "${pads}" ]]; then
    echo "No completed exercises yet — finish one first." >&2
    return 1
  fi
  csv="$(paste -sd, - <<< "${pads}")"

  _ensure_log
  printf '%s %s %s\n' "$(date +%s)" "$(( minutes * 60 ))" "${csv}" > "$(_exam_file)"
  _log_append "$(_today)" "exam-set" "${csv}"

  # Task sheet with the Task section of every exercise in the exam.
  sheet="$(_exam_sheet_file)"
  : > "${sheet}"
  while IFS= read -r pad; do
    file="$(_ex_file "${pad}")"
    {
      echo "## $(_ex_title "${file}")"
      echo
      _ex_task_text "${file}"
      echo
    } >> "${sheet}"
  done <<< "${pads}"

  # Countdown pane below the current one. -d keeps focus where it was.
  printf -v quoted_root '%q' "${ROOT_DIR}/scripts/tmux-trainer"
  tmux split-window -d -v -l 3 "${quoted_root} exam --timer"

  echo "EXAM — ${minutes} min, $(wc -w <<< "${pads}" | tr -d ' ') exercises"
  while IFS= read -r pad; do
    printf "  %s  %s\n" "${pad}" "$(_ex_title "$(_ex_file "${pad}")")"
  done <<< "${pads}"
  echo
  echo "Task sheet: ${sheet}"
  echo "Checks run automatically when the timer ends."
  echo "Finish early with: tmux-trainer exam finish"
}

_exam_finish() {  # scores the running exam and clears its state
  local f csv pad file line ex_pass ex_total total=0 passed=0
  local -a pads=()
  f="$(_exam_file)"
  if [[ ! -f "${f}" ]]; then
    echo "No exam is running." >&2
    return 1
  fi
  read -r _ _ csv < "${f}"
  rm -f "${f}"
  IFS=, read -r -a pads <<< "${csv}"

  for pad in "${pads[@]}"; do
    file="$(_ex_file "${pad}")"
    echo
    _ex_title "${file}"
    ex_pass=0; ex_total=0
    while IFS= read -r line; do
      [[ -z "${line}" ]] && continue
      ex_total=$(( ex_total + 1 ))
      if _run_assertion_line "${line}"; then
        ex_pass=$(( ex_pass + 1 ))
      fi
    done < <(_ex_check_lines "${file}")
    total=$(( total + ex_total ))
    passed=$(( passed + ex_pass ))
  done

  echo
  printf "Exam score: %d/%d checks passed\n" "${passed}" "${total}"
  _log_append "$(_today)" "exam-result" "${passed}/${total}"
  tmux display-message "tmux-trainer exam: ${passed}/${total} checks passed" \
    2>/dev/null || true
}

_exam_timer() {  # countdown inside the split pane
  local f start dur left
  f="$(_exam_file)"
  while [[ -f "${f}" ]]; do
    read -r start dur _ < "${f}" || break
    left=$(( start + dur - $(date +%s) ))
    if [[ "${left}" -le 0 ]]; then
      printf '\r\033[K  EXAM time is up, scoring...\n'
      _exam_finish > "$(_exam_results_file)" 2>&1 || true
      tail -n 1 "$(_exam_results_file)"
      sleep 10
      return 0
    fi
    printf '\r\033[K  EXAM  %02d:%02d left' "$(( left / 60 ))" "$(( left % 60 ))"
    sleep 1
  done
  printf '\r\033[K  EXAM ended\n'
  sleep 5
}

cmd_exam() {
  case "${1:-}" in
    finish)  _exam_finish ;;
    --timer) _exam_timer ;;
    *)
      local minutes="${1:-${EXAM_DEFAULT_MINUTES}}"
      if [[ ! "${minutes}" =~ ^[0-9]+$ ]] || [[ "${minutes}" -lt 1 ]]; then
        echo "Usage: tmux-trainer exam [MINUTES] | exam finish" >&2
        return 1
      fi
      _exam_start "${minutes}"
      ;;
  esac
}
