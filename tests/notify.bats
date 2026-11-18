#!/usr/bin/env bats
# Desktop notifications: clickable terminal-notifier path and the webhook
# guard for launcher-opened windows.

load helpers

setup() {
  tt_setup
  mkdir -p "${HOME}/.local/share/tmux-trainer" "${BATS_TEST_TMPDIR}/bin"
}

# Fake terminal-notifier that records its arguments.
make_notifier_stub() {
  cat > "${BATS_TEST_TMPDIR}/bin/terminal-notifier" <<STUB
#!/usr/bin/env bash
printf '%s\n' "\$@" > "${BATS_TEST_TMPDIR}/notifier-args.txt"
STUB
  chmod +x "${BATS_TEST_TMPDIR}/bin/terminal-notifier"
}

@test "launcher opens today's exercise and keeps the shell open" {
  tt_load_libs
  run _write_launcher 03
  [ "$status" -eq 0 ]
  local file="${TEMP_DIR}/tmux-trainer-open-03.command"
  [ -x "${file}" ]
  grep -q 'export TMUX_TRAINER_FROM_NOTIFICATION=1' "${file}"
  grep -q 'scripts/tmux-trainer 03' "${file}"
  grep -q 'exec "${SHELL:-/bin/zsh}" -l' "${file}"
}

@test "a notification with terminal-notifier opens the launcher on click" {
  make_notifier_stub
  PATH="${BATS_TEST_TMPDIR}/bin:${PATH}" env -u TMUX_TRAINER_NO_NOTIFY \
    "${TT}" 3 >/dev/null
  grep -qx -- '-execute' "${BATS_TEST_TMPDIR}/notifier-args.txt"
  grep -q 'open .*tmux-trainer-open-03.command' \
    "${BATS_TEST_TMPDIR}/notifier-args.txt"
}

@test "no notification when NO_NOTIFY is set" {
  make_notifier_stub
  PATH="${BATS_TEST_TMPDIR}/bin:${PATH}" "${TT}" 3 >/dev/null
  [ ! -f "${BATS_TEST_TMPDIR}/notifier-args.txt" ]
}

@test "launcher-opened windows do not notify again" {
  make_notifier_stub
  PATH="${BATS_TEST_TMPDIR}/bin:${PATH}" env -u TMUX_TRAINER_NO_NOTIFY \
    TMUX_TRAINER_FROM_NOTIFICATION=1 "${TT}" 3 >/dev/null
  [ ! -f "${BATS_TEST_TMPDIR}/notifier-args.txt" ]
}

@test "launcher-opened windows do not post to the webhook again" {
  local capture="${BATS_TEST_TMPDIR}/webhook.json"
  cat > "${BATS_TEST_TMPDIR}/bin/curl" <<STUB
#!/usr/bin/env bash
printf '%s' "\$*" > "${capture}"
STUB
  chmod +x "${BATS_TEST_TMPDIR}/bin/curl"
  mkdir -p "${HOME}/.config/tmux-trainer"
  echo 'WEBHOOK_URL="https://hooks.example/test"' \
    > "${HOME}/.config/tmux-trainer/conf"
  PATH="${BATS_TEST_TMPDIR}/bin:${PATH}" TMUX_TRAINER_FROM_NOTIFICATION=1 \
    "${TT}" 3 >/dev/null
  [ ! -f "${capture}" ]
}
