# TODO

Improvement ideas for future assessment.
Items marked ⭐ have the highest expected impact on learning.
Effort: [S] hours · [M] days · [L] week+

---

## Progress tracking

**Deck-size guardrail** [S] — pure Bash
Warn when more than 10 outstanding exercises are queued for
review. Motor-skill research shows consolidation fails when
the brain is overloaded with too many new patterns per
session; 5–10 is the effective ceiling.

---

## Exercise verification

**Pane-content assertions** [M] — pure Bash
`tmux capture-pane -t TARGET -p` captures visible pane text.
A check script can grep for expected output: verify `date`
ran, confirm a `watch` process is visible, or check that
`tmux ls` output appeared in the pane. Covers days 3, 6,
9, 15.

---

## CLI gamification

**Timed mode for the final drill** [S] — pure Bash
For day 20, record `time_start` when the exercise opens and
`time_end` when `tmux-trainer done` is called. Print elapsed
time and compare against the 5-minute target in the
completion goal.

---

## Content and curriculum

**Random review drill** [M] — pure Bash
`./scripts/tmux-trainer review` picks a random completed
exercise from the log and re-runs it as a drill. Implements
interleaved practice — mixing past and present material
produces better long-term retention than blocked practice
(the "desirable difficulty" effect from cognitive science).

**Linux / notify-send support** [S] — pure Bash
A two-line guard that calls `notify-send` on Linux instead
of `osascript` broadens the audience at near-zero cost.
tmuxquest (the only other interactive tmux learning tool
found) is browser-only; a cross-platform CLI fills a real
gap.

**Plugin-aware exercises (weeks 5–6)** [M] — Bash + Markdown
Add 10 exercises covering tmux-resurrect (save/restore
sessions across reboots), tmux-continuum (auto-save), and
tmux-fingers (fast copy with on-screen hints). These bridge
"power user" and "daily driver" use and have no equivalent
in existing learn-tmux repos.

**Exercise tags and filtering** [S] — pure Bash
Add a `tags:` front-matter line to each exercise file
(`tags: copy-mode navigation`). Let users run
`tmux-trainer --tag copy-mode` to jump to a relevant
exercise. Useful for people who join mid-cycle or want to
drill a specific skill.

**Pane title display** [S] — pure Bash + tmux.conf
Add a day 10 bonus step showing `set -g pane-border-status`
with `pane-border-format '#{pane_title}'`. This is a
tmuxinator feature that many users discover late; surfacing
it early pays dividends in all subsequent workspace
exercises.

---

## Delivery and UX

**fzf-based exercise picker** [S] — pure Bash (needs fzf)
`./scripts/tmux-trainer menu` pipes all exercise titles into
`fzf` for fuzzy interactive selection. Falls back to
`select` if fzf is absent. Fzf is available via Homebrew
and most Linux package managers.

**Shell completions** [S] — pure Bash
Add `completions/tmux-trainer.bash` and
`completions/tmux-trainer.zsh` so `tmux-trainer <TAB>`
completes subcommands (`check`, `done`, `review`, `cheat`,
`menu`) and day numbers 1–24.

**Slack / Discord webhook reminder** [M] — pure Bash + curl
Read `TMUX_TRAINER_WEBHOOK_URL` from the environment or
config file. When set, POST today's exercise title and goal
to the webhook alongside the macOS notification. Enables
team-wide daily reminders with zero infrastructure.

**Respect `NO_COLOR` and terminal width** [S] — pure Bash
Check `NO_COLOR` and narrow terminals (`tput cols < 60`);
strip ANSI codes or shorten output accordingly. Matters when
the exercise output is displayed inside tmux itself.

---

## Architecture

**`tmux-trainer.conf` user config** [S] — pure Bash
Source optional overrides from
`~/.config/tmux-trainer/conf` (notification hour, webhook
URL, state file path, color toggle). Consolidates all user
settings instead of environment variables scattered across
shell profiles.

**Homebrew formula** [L] — requires tap maintenance
Package the trainer as a Homebrew formula for
`brew install tmux-trainer`. Significant ongoing maintenance
cost; only worth pursuing if the project gains external
users.

---

## Done

**State file** [S] — `~/.local/share/tmux-trainer/log`
Append-only log, one line per run. Format:
`YYYY-MM-DD DD completed|skipped`. Human-readable and
directly editable. Foundation for all progress features.

**Streak counter** [S]
Counts consecutive completed weekdays backwards from today.
Weekends are skipped transparently. Displayed on every run:
`🔥 5-day streak`.

**Week progress bar** [S]
`[████░] 4/5 this week` — shown on every run next to the
streak. On weekends anchors to the previous Friday.

**Completion flag — `tmux-trainer done`** [S]
Appends a `completed` entry for today. Prints updated streak
and bar. Calling it twice on the same day is a no-op.

**Milestone badges** [S]
Printed once when first earned, stored as `badge` lines in
the log: `first-done`, `first-week`, `first-cycle`.

**vimtutor-style exercise copy** [S]
Exercise is copied to `/tmp/tmux-trainer-day-NN.md` before
display. Refreshed only when source is newer. Annotations
survive re-runs of the same day.

**Cheat sheet — `tmux-trainer cheat`** [S]
Prints all `Ctrl-b` shortcuts from exercises 1 to today,
grouped by day, extracted live from the exercise files.
`--all` flag shows every exercise regardless of today's day.

**Live state verification — `tmux-trainer check`** [M]
Reads the `## Check` section from the exercise file and
verifies actual tmux state using 7 assertion types:
`session_exists`, `window_count`, `window_named`,
`pane_count`, `pane_running`, `option_set`, `file_exists`.
`## Check` sections added to 22 of 24 exercises (07 and 13
have no structural state to verify).

**Spaced repetition — `tmux-trainer skip`** [M]
SM-2 intervals: 1 → 3 → 7 → 21 days after each correct
recall; wrong answer resets to 1 day. Only explicitly-skipped
exercises enter the queue. `done` advances the interval for
queued exercises. SRS state in `~/.local/share/tmux-trainer/srs`.
Queue shown before calendar exercise when reviews are due.
