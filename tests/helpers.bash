# shellcheck shell=bash
# Shared test setup. Every test runs with an isolated HOME, a fixed date,
# and no desktop notifications.

tt_setup() {
  ROOT_DIR="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"
  export ROOT_DIR
  export HOME="${BATS_TEST_TMPDIR}/home"
  mkdir -p "${HOME}"
  export TMUX_TRAINER_TMP_DIR="${BATS_TEST_TMPDIR}"
  export TMUX_TRAINER_TODAY="2026-11-18"   # a Wednesday
  export TMUX_TRAINER_NO_NOTIFY=1
  export NO_COLOR=1
  export TT="${ROOT_DIR}/scripts/tmux-trainer"
}

# Source the libraries for unit tests (same order as the entry point).
tt_load_libs() {
  export LOG_DIR="${HOME}/.local/share/tmux-trainer"
  # shellcheck source=/dev/null
  source "${ROOT_DIR}/lib/config.sh"
  source "${ROOT_DIR}/lib/dates.sh"
  source "${ROOT_DIR}/lib/catalog.sh"
  source "${ROOT_DIR}/lib/state.sh"
  source "${ROOT_DIR}/lib/srs.sh"
  source "${ROOT_DIR}/lib/assert.sh"
  source "${ROOT_DIR}/lib/notify.sh"
}

# Create a one-exercise fixture directory whose ## Check block holds $1.
# Prints the directory path.
tt_fixture_dir() {
  local dir="${BATS_TEST_TMPDIR}/exercises"
  mkdir -p "${dir}"
  {
    echo "# Day 1 — Fixture"
    echo
    echo "Goal: Exercise used by the test suite."
    echo "tags: fixture, sessions"
    echo
    echo "## Check"
    echo
    echo '```text'
    echo "$1"
    echo '```'
    echo
    echo "Ctrl-b c       new window"
  } > "${dir}/day-01.md"
  echo "${dir}"
}
