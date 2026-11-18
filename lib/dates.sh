# shellcheck shell=bash
# Portable date helpers (GNU coreutils and BSD/macOS date).
# TMUX_TRAINER_TODAY=YYYY-MM-DD overrides "today" (used by tests).

_today() { echo "${TMUX_TRAINER_TODAY:-$(date +%Y-%m-%d)}"; }

_date_fmt() {  # _date_fmt YYYY-MM-DD FORMAT
  if date --version >/dev/null 2>&1; then
    date -d "$1" +"$2"
  else
    date -jf "%Y-%m-%d" "$1" +"$2"
  fi
}

_date_dow() { _date_fmt "$1" %u; }   # 1=Mon … 7=Sun
_dow_today() { _date_dow "$(_today)"; }
_week_today() { _date_fmt "$(_today)" %V; }

_date_sub() {  # _date_sub YYYY-MM-DD N   (subtract N days)
  local d="$1" n="$2"
  if date --version >/dev/null 2>&1; then
    date -d "${d} - ${n} days" +%Y-%m-%d
  else
    date -jf "%Y-%m-%d" -v-"${n}"d "${d}" +%Y-%m-%d
  fi
}

_date_add() {  # _date_add YYYY-MM-DD N   (add N days)
  local d="$1" n="$2"
  if date --version >/dev/null 2>&1; then
    date -d "${d} + ${n} days" +%Y-%m-%d
  else
    date -jf "%Y-%m-%d" -v+"${n}"d "${d}" +%Y-%m-%d
  fi
}
