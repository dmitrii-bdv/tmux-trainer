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
