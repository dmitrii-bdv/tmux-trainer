# Day 39 — Automatic Saves with tmux-continuum

Goal: Automate tmux-resurrect saves on a timer and restore your
tags: plugins recovery
last environment automatically on tmux start using
tmux-continuum.

## Background

tmux-continuum wraps tmux-resurrect: it triggers a save every N
minutes via a tmux hook, and optionally restores the last save
when the tmux server starts. No daemon, no cron — it piggybacks
on tmux's own event system.

Requires tmux-resurrect (day-38) to be installed first.

## Task

### Part 1 — add the plugin

Add after the resurrect line in `~/.tmux.conf`:

```text
set -g @plugin 'tmux-plugins/tmux-continuum'
```

Reload and install:

```text
Ctrl-b r
Ctrl-b I
```

### Part 2 — set the save interval

The default interval is 15 minutes. Set it to 5 for easier
testing:

```text
set -g @continuum-save-interval '5'
```

Reload to apply:

```text
Ctrl-b r
```

### Part 3 — enable automatic restore on server start

```text
set -g @continuum-restore 'on'
```

After setting this, the next `tmux new-session` (when no server
is running) automatically restores the last resurrect save — no
`Ctrl-b Ctrl-r` needed.

### Part 4 — verify continuum is active

Confirm the option is live:

```bash
tmux show-option -g @continuum-save-interval
```

Optionally surface the last-save timestamp in your status bar:

```text
set -g status-right "#{continuum_status} | %H:%M"
```

`#{continuum_status}` shows the time since the last auto-save.

### Part 5 — inspect auto-saves

After the interval elapses (or reduce to 1 minute for testing),
check for new timestamped files:

```bash
ls -lt ~/.local/share/tmux/resurrect/
```

Files appear automatically — no manual `Ctrl-b Ctrl-s` needed.

### Part 6 — test auto-restore

Kill the server:

```bash
tmux kill-server
```

Start a new session — it should restore your layout without
pressing `Ctrl-b Ctrl-r`:

```bash
tmux new-session
```

## Completion goal

1. Confirm `@continuum-save-interval` is set and tmux-continuum
   is installed.
2. Observe at least one auto-save file created without manually
   pressing `Ctrl-b Ctrl-s`.

## Check

```text
file_contains  ~/.tmux.conf tmux-continuum
file_contains  ~/.tmux.conf continuum-save-interval
file_exists    ~/.local/share/tmux/resurrect/last
```

---

## Workflow

1. Read this exercise, then practise the commands in tmux.
2. Run `tmux-trainer check` to verify your work.
3. Run `tmux-trainer done` when finished.
4. Run `tmux-trainer skip` to defer to another day.
