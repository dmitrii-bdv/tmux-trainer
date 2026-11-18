#!/usr/bin/env bats
# End-to-end tests that run scripts/tmux-trainer in an isolated HOME.

load helpers

setup() {
  tt_setup
  mkdir -p "${HOME}/.local/share/tmux-trainer"
}

@test "--version prints the release version" {
  run "${TT}" --version
  [ "$status" -eq 0 ]
  [ "$output" = "tmux-trainer 1.3.0" ]
}

@test "help lists every subcommand" {
  run "${TT}" help
  [ "$status" -eq 0 ]
  for cmd in menu done skip check cheat review "--tag" lint help; do
    grep -q -- "${cmd}" <<< "$output"
  done
}

@test "lint passes for the shipped exercises" {
  run "${TT}" lint
  [ "$status" -eq 0 ]
  [[ "$output" == *"41 exercises valid"* ]]
}

@test "lint fails on a malformed assertion" {
  export TMUX_TRAINER_EXERCISE_DIR
  TMUX_TRAINER_EXERCISE_DIR="$(tt_fixture_dir 'file_exists a b')"
  run "${TT}" lint
  [ "$status" -eq 1 ]
  [[ "$output" == *"expects 1 argument"* ]]
}

@test "showing a day writes the working copy and active marker" {
  run "${TT}" 3
  [ "$status" -eq 0 ]
  [ -f "${BATS_TEST_TMPDIR}/tmux-trainer-day-03.md" ]
  [ "$(cat "${HOME}/.local/share/tmux-trainer/current")" = "03" ]
  [[ "$output" == *"Day 3 — Panes"* ]]
}

@test "day numbers with a leading zero are accepted" {
  run "${TT}" 08
  [ "$status" -eq 0 ]
  [[ "$output" == *"Day 8"* ]]
}

@test "out-of-range day is rejected" {
  run "${TT}" 99
  [ "$status" -eq 1 ]
  [[ "$output" == *"between 1 and 41"* ]]
}

@test "done marks the active exercise and is idempotent per day" {
  "${TT}" 3 >/dev/null
  run "${TT}" done
  [ "$status" -eq 0 ]
  [[ "$output" == *"Day 03 marked as completed"* ]]
  grep -q '^2026-11-18 03 completed$' "${HOME}/.local/share/tmux-trainer/log"
  run "${TT}" done
  [[ "$output" == *"already marked done today"* ]]
}

@test "skip records the exercise and queues it for review" {
  run "${TT}" skip 5
  [ "$status" -eq 0 ]
  grep -q '^2026-11-18 05 skipped$' "${HOME}/.local/share/tmux-trainer/log"
  grep -qxF "$(printf '05\t2026-11-18\t0')" "${HOME}/.local/share/tmux-trainer/srs"
}

@test "review without history explains there is nothing to drill" {
  run "${TT}" review
  [ "$status" -eq 0 ]
  [[ "$output" == *"No completed exercises yet"* ]]
}

@test "--list-days and --list-tags feed the shell completions" {
  run "${TT}" --list-days
  [ "$(head -1 <<< "$output")" = "1" ]
  [ "$(tail -1 <<< "$output")" = "41" ]
  run "${TT}" --list-tags
  grep -qx "copy-mode" <<< "$output"
  grep -qx "jq" <<< "$output"
}

@test "--tag with an unknown tag fails with a message" {
  run "${TT}" --tag nosuchtag
  [ "$status" -eq 1 ]
  [[ "$output" == *"No exercises tagged 'nosuchtag'"* ]]
}

@test "check reports a passing fixture assertion" {
  touch "${BATS_TEST_TMPDIR}/marker.txt"
  export TMUX_TRAINER_EXERCISE_DIR
  TMUX_TRAINER_EXERCISE_DIR="$(tt_fixture_dir "file_exists ${BATS_TEST_TMPDIR}/marker.txt")"
  run "${TT}" check 1
  [ "$status" -eq 0 ]
  [[ "$output" == *"All 1 checks passed"* ]]
}

@test "check exits non-zero when an assertion fails" {
  export TMUX_TRAINER_EXERCISE_DIR
  TMUX_TRAINER_EXERCISE_DIR="$(tt_fixture_dir "file_exists ${BATS_TEST_TMPDIR}/none")"
  run "${TT}" check 1
  [ "$status" -eq 1 ]
  [[ "$output" == *"0/1 checks passed"* ]]
}

@test "cheat lists shortcuts from the requested exercises" {
  run "${TT}" cheat --all
  [ "$status" -eq 0 ]
  [[ "$output" == *"Ctrl-b"* ]]
}

@test "webhook payload is valid JSON even when the title has quotes" {
  local capture="${BATS_TEST_TMPDIR}/payload.json"
  mkdir -p "${BATS_TEST_TMPDIR}/bin" "${HOME}/.config/tmux-trainer"
  cat > "${BATS_TEST_TMPDIR}/bin/curl" <<STUB
#!/usr/bin/env bash
# Records the value passed to -d.
while [[ \$# -gt 0 ]]; do
  if [[ "\$1" == "-d" ]]; then printf '%s' "\$2" > "${capture}"; fi
  shift
done
STUB
  chmod +x "${BATS_TEST_TMPDIR}/bin/curl"
  echo 'WEBHOOK_URL="https://hooks.slack.com/services/test"' \
    > "${HOME}/.config/tmux-trainer/conf"

  PATH="${BATS_TEST_TMPDIR}/bin:${PATH}" run "${TT}" 3
  [ "$status" -eq 0 ]
  [ -f "${capture}" ]
  jq -e '.text | contains("Goal:")' "${capture}" >/dev/null
}
