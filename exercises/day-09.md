# Day 9 — Pane Synchronization

Goal: Send the same keystrokes to every pane at once —
useful for running a command on multiple hosts or
directories simultaneously.

## Task

Create a session with four panes in a tiled layout:

```bash
tmux new -s sync
tmux split-window -h
tmux split-window -v
tmux select-pane -t 0
tmux split-window -v
tmux select-layout tiled
```

Enable synchronization:

```text
Ctrl-b :setw synchronize-panes on
```

Now type any command — it appears in every pane at once:

```bash
hostname
date
pwd
```

Disable when done:

```text
Ctrl-b :setw synchronize-panes off
```

## Completion goal

Run `date` simultaneously across all four panes, then
disable synchronization and run different commands in
each pane independently.

## Check

```text
session_exists   sync
pane_count       sync 4
pane_contains    sync:0 hostname
```

---

## Workflow

1. Read this exercise, then practise the commands in tmux.
2. Run `tmux-trainer check` to verify your work.
3. Run `tmux-trainer done` when finished.
4. Run `tmux-trainer skip` to defer to another day.
