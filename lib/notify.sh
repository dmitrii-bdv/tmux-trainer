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

notify_desktop() {  # notify_desktop TITLE BODY
  [[ -n "${TMUX_TRAINER_NO_NOTIFY:-}" ]] && return 0
  local title="$1" body="$2"
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
