#!/usr/bin/env bats
# Exam mode: selection, scoring, and guard rails. The split-pane and
# countdown are tmux-only and are not covered here.

load helpers

setup() {
  tt_setup
  mkdir -p "${HOME}/.local/share/tmux-trainer"
}

load_exam_libs() {
  tt_load_libs
  # shellcheck source=/dev/null
  source "${ROOT_DIR}/lib/commands/exam.sh"
}

@test "exam picks the least-used completed exercises first" {
  export EXAM_SIZE=2
  load_exam_libs
  printf '%s\n' "2026-11-16 01 completed" "2026-11-17 02 completed" \
    "2026-11-18 03 completed" "2026-11-16 exam-set 01,01" \
    "2026-11-17 exam-set 02" > "${LOG_FILE}"
  run _exam_pick
  [ "$status" -eq 0 ]
  [ "$output" = $'03\n02' ]
}

@test "exam picks nothing when no exercise is completed" {
  export EXAM_SIZE=5
  load_exam_libs
  : > "${LOG_FILE}"
  run _exam_pick
  [ -z "$output" ]
}

@test "exam finish scores checks and logs the result" {
  export TMUX_TRAINER_EXERCISE_DIR
  TMUX_TRAINER_EXERCISE_DIR="$(tt_fixture_dir "file_exists ${BATS_TEST_TMPDIR}/marker")"
  touch "${BATS_TEST_TMPDIR}/marker"
  load_exam_libs
  printf '%s 1200 01\n' "$(date +%s)" > "$(_exam_file)"

  run cmd_exam finish
  [ "$status" -eq 0 ]
  [[ "$output" == *"Exam score: 1/1 checks passed"* ]]
  grep -q '^2026-11-18 exam-result 1/1$' "${LOG_FILE}"
  [ ! -f "$(_exam_file)" ]
}

@test "exam finish reports a failing check" {
  export TMUX_TRAINER_EXERCISE_DIR
  TMUX_TRAINER_EXERCISE_DIR="$(tt_fixture_dir "file_exists ${BATS_TEST_TMPDIR}/absent")"
  load_exam_libs
  printf '%s 1200 01\n' "$(date +%s)" > "$(_exam_file)"

  run cmd_exam finish
  [ "$status" -eq 0 ]
  [[ "$output" == *"Exam score: 0/1 checks passed"* ]]
}

@test "exam finish without a running exam fails" {
  load_exam_libs
  run cmd_exam finish
  [ "$status" -eq 1 ]
  [[ "$output" == *"No exam is running"* ]]
}

@test "exam refuses to start outside tmux" {
  run env -u TMUX "${TT}" exam
  [ "$status" -eq 1 ]
  [[ "$output" == *"runs inside tmux"* ]]
}

@test "exam rejects a non-numeric length" {
  run env -u TMUX "${TT}" exam abc
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage: tmux-trainer exam"* ]]
}

@test "exam appears in help" {
  run "${TT}" help
  [[ "$output" == *"exam [MIN]"* ]]
}
