# shellcheck shell=bash
# shellcheck disable=SC2034  # variables are read by sourcing scripts
# Configuration: version, paths, user config, display style.
# Sourced by scripts/tmux-trainer after ROOT_DIR is set.

TMUX_TRAINER_VERSION="1.1.0"

EXERCISE_DIR="${TMUX_TRAINER_EXERCISE_DIR:-${ROOT_DIR}/exercises}"
TEMP_DIR="${TMUX_TRAINER_TMP_DIR:-/tmp}"
LOG_DIR="${HOME}/.local/share/tmux-trainer"

SRS_INTERVALS=(1 3 7 21)
TIMED_DRILL_PAD="20"   # exercise that gets a timed-run record

# ── user config (~/.config/tmux-trainer/conf) ──────────────────────────────
WEBHOOK_URL=""
_conf="${HOME}/.config/tmux-trainer/conf"
# shellcheck disable=SC1090
[[ -f "${_conf}" ]] && source "${_conf}"
unset _conf

# Derived paths are computed after user config, which may override LOG_DIR.
LOG_FILE="${LOG_DIR}/log"
SRS_FILE="${LOG_DIR}/srs"
CURRENT_FILE="${LOG_DIR}/current"

# ── display style (NO_COLOR / narrow terminal) ─────────────────────────────
_cols="$(tput cols 2>/dev/null || echo 80)"
if [[ -n "${NO_COLOR:-}" ]] || [[ "${_cols}" -lt 60 ]]; then
  IC_FIRE=">"; IC_BOOKS=">"; IC_WARN="!"
  IC_CHECK="+"; IC_CROSS="-"; IC_DICE="~"; IC_TIMER="~"
  IC_BADGE="*"; NARROW=1
else
  IC_FIRE="🔥"; IC_BOOKS="📚"; IC_WARN="⚠ "
  IC_CHECK="✓"; IC_CROSS="✗"; IC_DICE="🎲"; IC_TIMER="⏱ "
  IC_BADGE="🏅"; NARROW=0
fi
unset _cols
