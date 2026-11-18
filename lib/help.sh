# shellcheck shell=bash
# Single source for help output and the man page.
# Each row: usage | aliases | summary   (fields separated by "|")

_command_rows() {
  cat <<ROWS
(no args)||today's exercise (SRS queue first)
DAY||open a specific exercise by number (1–${TOTAL_EXERCISES})
menu|m|pick any exercise with fzf
done|d|mark the current exercise completed
skip [N]|s [N]|defer the current (or Nth) exercise to the SRS queue
check [N]|c [N]|verify your live tmux state against the exercise
cheat [--all]||print Ctrl-b shortcuts (up to today, or all with --all)
review|r|open a random completed exercise as a drill
--tag NAME||filter exercises by tag and pick one with fzf
lint||validate all exercise files (for contributors)
help|h|show this page
--version||print the version
ROWS
}

_command_summary_text() {  # the summaries used by both help and man
  cat <<'TEXT'
Assertion types for check: session_exists, window_count, window_named,
pane_count, pane_running, option_set, file_exists, pane_contains,
file_contains.
TEXT
}

_help_examples() {
  cat <<'TEXT'
tmux-trainer              today's exercise
tmux-trainer 7            exercise 7
tmux-trainer m            pick with fzf
tmux-trainer d            mark complete
tmux-trainer c            verify tmux state
tmux-trainer cheat        shortcut reference
tmux-trainer r            random drill
tmux-trainer --tag config all config exercises
TEXT
}

_help_files() {
  cat <<TEXT
~/.local/share/tmux-trainer/log      completion log
~/.local/share/tmux-trainer/srs      SRS queue state
~/.local/share/tmux-trainer/current  last opened exercise
/tmp/tmux-trainer-day-NN.md          annotatable working copy
TEXT
}

_help_license() {
  cat <<'TEXT'
PolyForm Noncommercial License 1.0.0 (see LICENSE in the repo).
Noncommercial use is free. Commercial use requires permission:
dmitrii@bedov.ch
TEXT
}

cmd_help() {
  local usage aliases summary label
  cat <<HEADER

NAME
    tmux-trainer — daily tmux exercise trainer

SYNOPSIS
    tmux-trainer [DAY]
    tmux-trainer <subcommand> [args]

DESCRIPTION
    Delivers one tmux exercise per working day. Tracks completions,
    streaks, and spaced-repetition reviews.

SUBCOMMANDS
HEADER
  while IFS='|' read -r usage aliases summary; do
    label="${usage}"
    [[ -n "${aliases}" ]] && label="${usage}  | ${aliases}"
    printf "    %-24s %s\n" "${label}" "${summary}"
  done < <(_command_rows)

  cat <<'KEYBIND'

TMUX KEYBINDING
    Trigger a random drill from any tmux window with Prefix+r.
    Add to ~/.tmux.conf:

        bind-key r run-shell "tmux-trainer review"

FILES
KEYBIND
  _help_files | sed 's/^/    /'
  echo
  echo "EXAMPLES"
  _help_examples | sed 's/^/    /'
  echo
  _command_summary_text | sed 's/^/    /'
  echo
  echo "LICENSE"
  _help_license | sed 's/^/    /'
  echo
}

_troff_escape() { sed -e 's/\\/\\e/g' -e 's/-/\\-/g'; }

cmd_man_install() {
  local dir="${HOME}/.local/share/man/man1"
  mkdir -p "${dir}"
  _generate_man > "${dir}/tmux-trainer.1"
  echo "man page installed → ${dir}/tmux-trainer.1"
}

_generate_man() {
  cat <<TROFF
.TH TMUX-TRAINER 1 "" "tmux-trainer ${TMUX_TRAINER_VERSION}" "User Commands"
.SH NAME
tmux\\-trainer \\- daily tmux exercise trainer
.SH SYNOPSIS
.B tmux-trainer
.RI [ DAY ]
.br
.B tmux-trainer
.I subcommand
.RI [ args ]
.SH DESCRIPTION
Delivers one tmux exercise per working day.
Tracks completions, streaks, and spaced-repetition reviews.
.SH SUBCOMMANDS
TROFF
  local usage aliases summary
  while IFS='|' read -r usage aliases summary; do
    printf '.TP\n.B %s\n' "$(printf '%s' "${usage}" | _troff_escape)"
    if [[ -n "${aliases}" ]]; then
      printf 'alias: %s\n' "$(printf '%s' "${aliases}" | _troff_escape)"
    fi
    printf '%s\n' "$(printf '%s' "${summary}" | _troff_escape)"
  done < <(_command_rows)
  cat <<TROFF
.SH FILES
.nf
$(_help_files | _troff_escape)
.fi
.SH TMUX KEYBINDING
Trigger a random drill from any tmux window with Prefix+r.
Add to
.IR ~/.tmux.conf :
.PP
.nf
    bind-key r run-shell "tmux-trainer review"
.fi
.SH EXAMPLES
.nf
$(_help_examples | _troff_escape)
.fi
.SH ASSERTIONS
$(_command_summary_text | _troff_escape)
.SH LICENSE
$(_help_license | _troff_escape)
.SH AUTHOR
Written by DiBDV. Source: https://github.com/DiBDV/tmux-trainer
TROFF
}
