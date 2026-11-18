# shellcheck shell=bash
# Outbound notifications: desktop (macOS / Linux) and webhook
# (Telegram, Slack, Discord). Text is escaped before it is embedded.

_json_escape() {  # backslash, quote, and newline escaping for JSON strings
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  printf '%s' "${s}"
}

_applescript_escape() {  # backslash and quote escaping for AppleScript
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  printf '%s' "${s}"
}

_terminal_notifier() {  # prints the terminal-notifier path, if installed
  local p
  if p="$(command -v terminal-notifier 2>/dev/null)" && [[ -n "${p}" ]]; then
    echo "${p}"; return 0
  fi
  # launchd runs without the Homebrew PATH, so check the usual locations.
  for p in /opt/homebrew/bin/terminal-notifier /usr/local/bin/terminal-notifier; do
    if [[ -x "${p}" ]]; then echo "${p}"; return 0; fi
  done
  return 1
}

_write_launcher() {  # _write_launcher PAD -> prints the .command file path
  # macOS opens .command files in the default terminal app. The launcher
  # shows the exercise and keeps the shell open. It sets the flag so that
  # showing the exercise does not notify or post to the webhook again.
  local pad="$1" file
  file="${TEMP_DIR}/tmux-trainer-open-${pad}.command"
  {
    echo '#!/usr/bin/env bash'
    echo 'export TMUX_TRAINER_FROM_NOTIFICATION=1'
    # shellcheck disable=SC2016  # the launcher expands these at run time
    echo 'cd "$HOME" || exit 1'
    printf '%q %s\n' "${ROOT_DIR}/scripts/tmux-trainer" "${pad}"
    # shellcheck disable=SC2016
    echo 'exec "${SHELL:-/bin/zsh}" -l'
  } > "${file}"
  chmod +x "${file}"
  echo "${file}"
}

notify_desktop() {  # notify_desktop TITLE BODY [PAD]
  [[ -n "${TMUX_TRAINER_NO_NOTIFY:-}" ]] && return 0
  [[ -n "${TMUX_TRAINER_FROM_NOTIFICATION:-}" ]] && return 0
  local title="$1" body="$2" pad="${3:-}" tn launcher
  if [[ -n "${pad}" ]] && tn="$(_terminal_notifier)"; then
    launcher="$(_write_launcher "${pad}")"
    "${tn}" -title "tmux trainer" -subtitle "${title}" -message "${body}" \
      -group "tmux-trainer" \
      -execute "open $(printf '%q' "${launcher}")" >/dev/null 2>&1 || true
    return 0
  fi
  if command -v osascript >/dev/null 2>&1; then
    osascript -e "display notification \"$(_applescript_escape "${body}")\" \
with title \"tmux trainer\" subtitle \"$(_applescript_escape "${title}")\"" \
      >/dev/null 2>&1 || true
  elif command -v notify-send >/dev/null 2>&1; then
    notify-send "tmux trainer — ${title}" "${body}" || true
  fi
  return 0
}

send_webhook() {  # send_webhook TITLE GOAL
  [[ -n "${WEBHOOK_URL}" ]] || return 0
  [[ -n "${TMUX_TRAINER_FROM_NOTIFICATION:-}" ]] && return 0
  local msg payload
  msg="tmux trainer — $1"$'\n'"Goal: $2"$'\n'"Run: tmux-trainer"
  # Discord expects "content"; Telegram and Slack expect "text".
  if [[ "${WEBHOOK_URL}" == *"discord.com/api/webhooks"* ]]; then
    payload="{\"content\":\"$(_json_escape "${msg}")\"}"
  else
    payload="{\"text\":\"$(_json_escape "${msg}")\"}"
  fi
  curl -s -o /dev/null --max-time 5 \
    -H 'Content-Type: application/json' \
    -d "${payload}" \
    "${WEBHOOK_URL}" || true
  return 0
}
