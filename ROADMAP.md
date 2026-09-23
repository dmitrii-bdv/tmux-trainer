# Roadmap

Ordered highest → lowest learning impact.
Pick from the top — earlier items unlock later ones.

Effort: [S] hours · [M] days · [L] week+
Deps listed only when a prior item is a hard prerequisite.

---

## Tier 2 — Close the verification gap

### 6. Pane-content assertions [M]

Dep: `tmux-trainer check` (done).

Extend check with a `pane_contains` assertion that runs
`tmux capture-pane -t TARGET -p` and greps for expected output.
Example for day 7 (copy mode):

```text
pane_contains  training:shell.0  "line 50"
```

Covers days 3, 6, 9, 15 where the correct output is observable
in the pane itself.

---

## Tier 3 — Reduce daily friction

### 11. Random review drill [M]

Dep: state file (done).

```bash
tmux-trainer review
```

Pick a random `completed` exercise from the log and re-run it
as a drill. Implements interleaved practice — mixing past and
present material produces better long-term retention than blocked
practice (the "desirable difficulty" effect).

---

## Tier 4 — Content and curriculum expansion

### 13. Linux / notify-send support [S]

Guard the notification call by OS:

```bash
if [[ "$(uname)" == "Linux" ]]; then
  notify-send "tmux trainer" "${TITLE}"
fi
```

Two-line change. Fills a real gap — tmuxquest, the only other
interactive tmux learning tool found, is browser-only.

### 14. Timed mode for day-20 final drill [S]

Dep: `done` subcommand (done).

Record `time_start` when day 20 opens. When `tmux-trainer done`
is called, compute elapsed time and compare against the 5-minute
target:

```text
✓ Completed in 4m 22s  (target: < 5m)
```

### 15. Exercise tags and filtering [S]

Add a `tags:` front-matter line to each exercise:

```text
tags: copy-mode navigation
```

```bash
tmux-trainer --tag copy-mode
```

Lets users who join mid-cycle or want to drill a specific skill
jump directly to relevant exercises.

### 17. Plugin-aware exercises (weeks 5–6) [M]

Add 10 exercises covering tmux-resurrect (session save/restore
across reboots), tmux-continuum (auto-save), and tmux-fingers
(fast on-screen copy hints). No comparable exercises exist in
any other learn-tmux repo found.

### 18. Pane title display [S]

Add a step to day 10 showing:

```text
set -g pane-border-status top
set -g pane-border-format ' #{pane_title} '
```

Commonly discovered late by tmux users; surfacing it early pays
off in all subsequent workspace exercises.

---

## Tier 5 — Polish and infrastructure

### 19. Shell completions [S]

Add `completions/tmux-trainer.bash` and
`completions/tmux-trainer.zsh` so `tmux-trainer <TAB>` completes
subcommands (`done`, `skip`, `check`, `review`, `cheat`, `menu`)
and day numbers 1–24.

### 20. `tmux-trainer.conf` user config [S]

Source optional overrides from `~/.config/tmux-trainer/conf`:

```bash
NOTIFICATION_HOUR=08
WEBHOOK_URL=""
LOG_PATH="${HOME}/.local/share/tmux-trainer/log"
NO_COLOR=0
```

Consolidates all user settings instead of environment variables
scattered across shell profiles.

### 21. Respect `NO_COLOR` and terminal width [S]

Check `$NO_COLOR` and narrow terminals (`tput cols < 60`). Strip
ANSI codes or shorten output accordingly. Matters when the
exercise output is displayed inside a tmux pane itself.

### 22. Slack / Discord webhook reminder [M]

Read `TMUX_TRAINER_WEBHOOK_URL` from config. When set, POST
today's exercise title and goal to the webhook alongside the
macOS notification. Enables team-wide daily reminders with zero
infrastructure.

### 23. Homebrew formula [L]

Package as a Homebrew formula for `brew install tmux-trainer`.
Significant ongoing maintenance cost; only worth pursuing once
the project has external users.
