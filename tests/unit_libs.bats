#!/usr/bin/env bats
# Unit tests for lib/: dates, state, SRS, assertions, escaping.

load helpers

setup() {
  tt_setup
  tt_load_libs
  mkdir -p "${LOG_DIR}"
}

# --- dates ---------------------------------------------------------------

@test "_today honours TMUX_TRAINER_TODAY" {
  run _today
  [ "$output" = "2026-11-18" ]
}

@test "_date_dow: 2026-11-18 is a Wednesday (3)" {
  run _date_dow 2026-11-18
  [ "$output" = "3" ]
}

@test "_date_sub and _date_add cross month boundaries" {
  run _date_sub 2026-12-01 1
  [ "$output" = "2026-11-30" ]
  run _date_add 2026-11-30 1
  [ "$output" = "2026-12-01" ]
}

# --- catalog -------------------------------------------------------------

@test "catalog counts the 41 shipped exercises" {
  [ "${TOTAL_EXERCISES}" -eq 41 ]
}

@test "_pad accepts unpadded and octal-looking numbers" {
  [ "$(_pad 7)" = "07" ]
  [ "$(_pad 08)" = "08" ]
  [ "$(_pad 09)" = "09" ]
}

@test "_current_day stays inside 1..TOTAL for any week" {
  for d in 2026-01-05 2026-02-23 2026-03-02 2026-11-18 2026-12-31; do
    TMUX_TRAINER_TODAY="$d"
    run _current_day
    [ "$status" -eq 0 ]
    [ "$output" -ge 1 ] && [ "$output" -le "${TOTAL_EXERCISES}" ]
  done
}

@test "_ex_has_tag matches whole tags only" {
  local f="${EXERCISE_DIR}/day-01.md"
  _ex_has_tag "$f" sessions
  run _ex_has_tag "$(_ex_file 30)" mode
  [ "$status" -ne 0 ]
}

# --- state ---------------------------------------------------------------

@test "streak counts weekdays back from today, skipping weekends" {
  printf '%s\n' \
    "2026-11-18 01 completed" \
    "2026-11-17 02 completed" \
    "2026-11-16 03 completed" \
    "2026-11-13 04 completed" \
    "2026-11-12 05 completed" > "${LOG_FILE}"
  run _streak
  [ "$output" = "5" ]
}

@test "streak stops at the first missing weekday" {
  printf '%s\n' "2026-11-18 01 completed" "2026-11-16 02 completed" \
    > "${LOG_FILE}"
  run _streak
  [ "$output" = "1" ]
}

@test "week bar counts completions Monday to today" {
  printf '%s\n' "2026-11-16 01 completed" "2026-11-17 02 completed" \
    "2026-11-18 03 completed" > "${LOG_FILE}"
  run _week_bar
  [ "$output" = "[███░░] 3/5 this week" ]
}

@test "today status reports completed and skipped" {
  printf '%s\n' "2026-11-18 07 skipped" "2026-11-18 08 completed" \
    > "${LOG_FILE}"
  [ "$(_today_status 07)" = "skipped" ]
  [ "$(_today_status 08)" = "completed" ]
  [ "$(_today_status 09)" = "none" ]
}

# --- SRS -----------------------------------------------------------------

@test "skipped exercise is queued with zero reps" {
  _srs_update 05 0
  grep -qxF "$(printf '05\t2026-11-18\t0')" "${SRS_FILE}"
}

@test "correct recall of an unqueued exercise creates no queue entry" {
  _srs_update 05 1
  [ ! -f "${SRS_FILE}" ]
}

@test "correct recall advances reps and caps at 3" {
  _srs_update 05 0
  _srs_update 05 1
  _srs_update 05 1
  _srs_update 05 1
  _srs_update 05 1
  grep -qxF "$(printf '05\t2026-11-18\t3')" "${SRS_FILE}"
}

@test "a failed recall resets reps to zero" {
  _srs_update 05 0
  _srs_update 05 1
  _srs_update 05 0
  grep -qxF "$(printf '05\t2026-11-18\t0')" "${SRS_FILE}"
}

@test "entry is due once its interval has elapsed" {
  printf '05\t2026-11-17\t0\n' > "${SRS_FILE}"   # interval 1 day
  run _srs_due_list
  [ "$output" = "05" ]
}

@test "entry is not due before its interval elapses" {
  printf '05\t2026-11-18\t1\n' > "${SRS_FILE}"   # interval 3 days
  run _srs_due_list
  [ -z "$output" ]
}

# --- assertions ----------------------------------------------------------

@test "split_args honours double and single quotes" {
  _split_args "file_contains ~/x.conf \"a b\" 'c d'"
  [ "${#ARGS[@]}" -eq 4 ]
  [ "${ARGS[2]}" = "a b" ]
  [ "${ARGS[3]}" = "c d" ]
}

@test "validate rejects unknown types and wrong arity" {
  run _validate_assertion_line "bogus x"
  [ "$status" -ne 0 ]
  run _validate_assertion_line "window_count only-one"
  [ "$status" -ne 0 ]
  run _validate_assertion_line "file_exists /tmp/my file.txt"
  [ "$status" -ne 0 ]
}

@test "validate accepts well-formed lines" {
  run _validate_assertion_line 'file_exists "/tmp/my file.txt"'
  [ "$status" -eq 0 ]
  run _validate_assertion_line "option_set mouse on"
  [ "$status" -eq 0 ]
}

@test "file_exists passes for an existing file and fails otherwise" {
  touch "${BATS_TEST_TMPDIR}/present.txt"
  run _run_assertion_line "file_exists ${BATS_TEST_TMPDIR}/present.txt"
  [ "$status" -eq 0 ]
  run _run_assertion_line "file_exists ${BATS_TEST_TMPDIR}/absent.txt"
  [ "$status" -ne 0 ]
}

@test "file_contains matches literal text, not a regex" {
  printf 'set -g status-format[1] "x"\n' > "${BATS_TEST_TMPDIR}/conf"
  run _run_assertion_line "file_contains ${BATS_TEST_TMPDIR}/conf status-format[1]"
  [ "$status" -eq 0 ]
}

@test "file_contains supports quoted multi-word needles" {
  printf 'event 20 fired\n' > "${BATS_TEST_TMPDIR}/dump"
  run _run_assertion_line "file_contains ${BATS_TEST_TMPDIR}/dump \"event 20\""
  [ "$status" -eq 0 ]
}

# --- escaping ------------------------------------------------------------

@test "json escape handles quotes, backslashes, and newlines" {
  run _json_escape 'say "hi"\ now'$'\n''ok'
  [ "$output" = 'say \"hi\"\\ now\nok' ]
}

@test "applescript escape handles quotes and backslashes" {
  run _applescript_escape 'a "b" \c'
  [ "$output" = 'a \"b\" \\c' ]
}
