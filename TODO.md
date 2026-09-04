# TODO

Improvement ideas for future assessment.
Items marked ⭐ have the highest expected impact on learning.
Effort: [S] hours · [M] days · [L] week+

---

## Progress tracking

⭐ **State file** [S] — pure Bash
Track completions in an append-only log at
`~/.local/share/tmux-trainer/log` — one line per run:

```text
2026-09-04 20 completed
2026-09-05 20 skipped
```

This is the habitctl pattern: human-readable, directly
editable, trivially parsed with `awk`. Everything else in
this file depends on this existing first.

**Streak counter** [S] — pure Bash
Read the log and count consecutive `completed` days. Display
on every run (`🔥 12-day streak`). Streaks are the single
most effective retention mechanism in daily-habit tools
(Duolingo, GitHub contributions, dijo, habitctl).

⭐ **Spaced repetition re-queue** [M] — pure Bash
Flag exercises the user skipped or marked incomplete, then
re-surface them on a schedule derived from the SM-2
algorithm: 1 day → 3 days → 7 days → 21 days after each
correct recall. Wrong answer resets the interval to 0.
Research on shortcut learning (KeyCombiner, Anki) shows this
produces significantly better long-term retention than fixed
weekly repetition. Requires the state file above.

**Deck-size guardrail** [S] — pure Bash
Warn when more than 10 outstanding exercises are queued for
review. Motor-skill research shows consolidation fails when
the brain is overloaded with too many new patterns per
session; 5–10 is the effective ceiling.

**Week progress indicator** [S] — pure Bash
Print a compact ASCII bar (`[████░] 4/5 this week`) on each
run. Low effort, high motivation signal.

---

## Exercise verification

⭐ **`tmux-trainer check` subcommand** [M] — pure Bash
After completing an exercise, `./scripts/tmux-trainer check`
verifies the completion goal using live tmux state. Each
exercise can carry a `## Check` section with assertions:

```text
session_exists training
window_count   training 4
window_named   training kube
pane_count     training:kube 2
pane_running   training:kube.0 watch
```

Use these tmux queries to implement assertions:

```bash
# session and window existence
tmux list-sessions -F '#{session_name}'
tmux list-windows -t SESSION -F '#{window_name}'

# pane counts and running commands
tmux list-panes -t SESSION:WINDOW \
  -F '#{pane_index} #{pane_current_command}'
tmux display-message -p -t SESSION:WINDOW.PANE \
  '#{pane_current_command}'

# option values (day 10 / day 19 checks)
tmux show-options -g history-limit
tmux show-options -g mouse

# key bindings (day 10 check)
tmux list-keys -N   # keys with notes only
```

**Important limitation**: tmux exposes no `last_key` format
variable and no key-press history. Behavioral verification
(did you use `Ctrl-b` rather than clicking) is not possible
via tmux introspection alone. Structural checks (does the
session/window/pane exist, what command is running) are
sufficient for most exercises.

**Pane-content assertions** [M] — pure Bash
`tmux capture-pane -t TARGET -p` captures visible pane text.
A check script can grep for expected output: verify `date`
ran, confirm a `watch` process is visible, or check that
`tmux ls` output appeared in the pane. Covers days 3, 6,
9, 15.

---

## CLI gamification

**Completion flag** [S] — pure Bash
`./scripts/tmux-trainer done` appends a `completed` entry to
the log. Intentionally manual — the user decides when they
are done, which forces honest self-assessment.

**Milestone badges** [S] — pure Bash
Print a one-line badge the first time a threshold fires:
first completion, first full week, first full cycle. Store
which badges fired in the log (one line each:
`2026-09-04 badge first-week`). No server needed.

**Timed mode for the final drill** [S] — pure Bash
For day 20, record `time_start` when the exercise opens and
`time_end` when `tmux-trainer done` is called. Print elapsed
time and compare against the 5-minute target in the
completion goal.

---

## Content and curriculum

⭐ **vimtutor-style exercise copy** [S] — pure Bash
When displaying an exercise, open a temp copy
(`/tmp/tmux-trainer-day-NN.md`) rather than the source file.
The user can annotate it freely (cross off steps, add notes)
without dirtying the repo. This is the pattern vimtutor uses
to lower the activation barrier for experimentation.

**Cheat sheet command** [S] — pure Bash
`./scripts/tmux-trainer cheat` prints every shortcut
introduced up to today's exercise in a compact table. Use
`tmux list-keys -N` to cross-reference against what tmux
actually has bound. Avoids mid-exercise web searches.

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
`menu`) and day numbers 1–20.

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
