# Roadmap

Ordered highest → lowest learning impact.
Pick from the top — earlier items unlock later ones.

Effort: [S] hours · [M] days · [L] week+
Deps listed only when a prior item is a hard prerequisite.

---

## Tier 1 — Fix the broken feedback loop

The trainer currently has no memory and no feedback.
You do an exercise and nothing happens. These four items
close that gap and are the foundation for everything else.

### 1. State file [S]

Add an append-only log at
`~/.local/share/tmux-trainer/log`:

```text
2026-09-04 20 completed
2026-09-05 18 skipped
```

One line per run, written by `tmux-trainer done` (item 2)
and `tmux-trainer skip`. Parse with `awk`. No database,
no JSON. Every other tracking feature depends on this.

### 2. `tmux-trainer done` and `skip` flags [S]

Dep: item 1.

```bash
./scripts/tmux-trainer done    # appends "completed"
./scripts/tmux-trainer skip    # appends "skipped"
```

Intentionally manual — the user decides when they are done,
which forces honest self-assessment. Add a reminder line
at the end of every exercise output:

```text
When finished: ./scripts/tmux-trainer done
```

### 3. Streak counter [S]

Dep: item 1.

Read the log and count consecutive `completed` days.
Print on every run:

```text
🔥 Day 8 — Sessions  [streak: 12]
```

Streaks are the single most effective retention mechanism
in daily-habit tools (Duolingo, GitHub contributions,
habitctl). Small to build, high motivation payoff.

### 4. Week progress indicator [S]

Dep: item 1.

Print a compact ASCII bar on each run:

```text
Week 1  [████░]  4 / 5
```

Gives immediate visible progress without needing a
separate dashboard. Two lines of awk.

---

## Tier 2 — Close the verification gap

Right now there is no way to know whether an exercise
was actually completed correctly. These items give the
trainer eyes into the live tmux state.

### 5. `tmux-trainer check` subcommand [M]

Add a `## Check` block to each exercise file containing
machine-readable assertions:

```text
session_exists  training
window_count    training 4
window_named    training kube
pane_count      training:kube 2
pane_running    training:kube.0 watch
```

`./scripts/tmux-trainer check` reads the block and
evaluates each assertion using:

```bash
tmux list-sessions  -F '#{session_name}'
tmux list-windows   -t SESSION -F '#{window_name}'
tmux list-panes     -t SESSION:WINDOW \
  -F '#{pane_index} #{pane_current_command}'
tmux show-options   -g history-limit
tmux list-keys      -N
```

Note: tmux has no `last_key` variable, so behavioral
verification (did you press `Ctrl-b` vs click) is not
possible. Structural checks are sufficient for most
exercises.

### 6. Pane-content assertions [M]

Dep: item 5.

Extend check with a `pane_contains` assertion that runs
`tmux capture-pane -t TARGET -p` and greps for expected
output. Example for day 7 (copy mode):

```text
pane_contains  training:shell.0  "line 50"
```

Covers days 3, 6, 9, 15 where the correct output is
observable in the pane itself.

---

## Tier 3 — Reduce daily friction

High ROI, low effort. Each of these removes a moment of
resistance that currently interrupts the exercise flow.

### 7. vimtutor-style exercise copy [S]

When displaying an exercise, copy it to a temp file:

```bash
cp "${EXERCISE}" "/tmp/tmux-trainer-day-${DAY_PADDED}.md"
```

Open the copy instead of the source. The user can cross
off steps and add inline notes without dirtying the repo.
This is the exact pattern vimtutor uses to lower the
activation barrier for experimentation.

### 8. Cheat sheet command [S]

```bash
./scripts/tmux-trainer cheat
```

Print every shortcut introduced up to today's exercise
in a compact table. Use `tmux list-keys -N` to confirm
the binding is actually live. Eliminates mid-exercise
web searches, which break flow.

### 9. fzf exercise picker [S]

```bash
./scripts/tmux-trainer menu
```

Pipe all 20 exercise titles into `fzf` for fuzzy
interactive selection. Fall back to `select` if fzf is
absent. Useful for jumping to a specific topic or
replaying a past exercise.

---

## Tier 4 — Long-term retention

These apply learning-science techniques. They depend on
the state file and add measurable retention benefit after
the first cycle completes.

### 10. Spaced repetition re-queue [M]

Dep: items 1 and 5.

Re-surface exercises the user skipped or failed on an
SM-2 schedule: 1 day → 3 days → 7 days → 21 days after
each correct recall. Wrong answer resets the interval.
Research on shortcut learning (KeyCombiner, Anki) shows
this produces significantly better retention than fixed
weekly repetition. Override the ISO-week formula when a
review exercise is due.

### 11. Random review drill [M]

Dep: item 1.

```bash
./scripts/tmux-trainer review
```

Pick a random `completed` exercise from the log and
re-run it as a drill. Implements interleaved practice —
mixing past and present material produces better
long-term retention than blocked practice (the
"desirable difficulty" effect).

### 12. Deck-size guardrail [S]

Dep: item 10.

Warn when more than 10 exercises are queued for spaced-
repetition review:

```text
⚠ 11 reviews due — consider a catch-up session first.
```

Motor-skill research shows consolidation degrades when
the learner is overloaded with too many new patterns
per session. 5–10 is the effective ceiling.

---

## Tier 5 — Content and curriculum expansion

### 13. Linux / notify-send support [S]

Guard the notification call by OS:

```bash
if [[ "$(uname)" == "Linux" ]]; then
  notify-send "tmux trainer" "${TITLE}"
fi
```

Two-line change. tmuxquest — the only other interactive
tmux learning tool found — is browser-only. A cross-
platform CLI fills a real gap and costs almost nothing.

### 14. Timed mode for day-20 final drill [S]

Dep: item 2.

Record `time_start` when day 20 opens. When
`tmux-trainer done` is called, compute elapsed time and
compare against the 5-minute target:

```text
✓ Completed in 4m 22s  (target: < 5m)
```

High value for the capstone exercise specifically.

### 15. Exercise tags and filtering [S]

Add a `tags:` front-matter line to each exercise:

```text
tags: copy-mode navigation
```

```bash
./scripts/tmux-trainer --tag copy-mode
```

Lets users who join mid-cycle or want to drill a
specific skill jump directly to relevant exercises.

### 16. Milestone badges [S]

Dep: item 1.

Print a one-line badge the first time a threshold fires:

```text
🏅 First full week complete.
🏅 First full 4-week cycle complete.
```

Store fired badges in the log (`badge first-week`).
No server needed.

### 17. Plugin-aware exercises (weeks 5–6) [M]

Add 10 exercises covering tmux-resurrect (session
save/restore across reboots), tmux-continuum (auto-
save), and tmux-fingers (fast on-screen copy hints).
Bridges the gap between power user and daily driver.
No comparable exercises exist in any other learn-tmux
repo found.

### 18. Pane title display [S]

Add a step to day 10 showing:

```text
set -g pane-border-status top
set -g pane-border-format ' #{pane_title} '
```

This feature is commonly discovered late by tmux users;
surfacing it early pays off in all subsequent workspace
exercises.

---

## Tier 6 — Polish and infrastructure

Low individual impact but collectively improve the
long-term maintainability and reach of the project.

### 19. Shell completions [S]

Add `completions/tmux-trainer.bash` and
`completions/tmux-trainer.zsh` so `tmux-trainer <TAB>`
completes subcommands (`done`, `skip`, `check`,
`review`, `cheat`, `menu`) and day numbers 1–20.

### 20. `tmux-trainer.conf` user config [S]

Source optional overrides from
`~/.config/tmux-trainer/conf`:

```bash
NOTIFICATION_HOUR=08
WEBHOOK_URL=""
LOG_PATH="${HOME}/.local/share/tmux-trainer/log"
NO_COLOR=0
```

Consolidates all user settings instead of environment
variables scattered across shell profiles.

### 21. Respect `NO_COLOR` and terminal width [S]

Check `$NO_COLOR` and narrow terminals
(`tput cols < 60`). Strip ANSI codes or shorten output
accordingly. Matters when the exercise output is
displayed inside a tmux pane itself.

### 22. Slack / Discord webhook reminder [M]

Read `TMUX_TRAINER_WEBHOOK_URL` from config. When set,
POST today's exercise title and goal to the webhook
alongside the macOS notification. Enables team-wide
daily reminders with zero infrastructure.

### 23. Homebrew formula [L]

Package the trainer as a Homebrew formula for
`brew install tmux-trainer`. Significant ongoing
maintenance cost; only worth pursuing once the project
has external users.
