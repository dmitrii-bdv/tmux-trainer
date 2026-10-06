# Day 38 — Session Persistence with tmux-resurrect

Goal: Save and restore your entire tmux environment — sessions,
tags: plugins recovery
windows, panes, and running programs — across restarts using
tmux-resurrect.

## Background

tmux-resurrect captures the full layout (session names, window
names, pane splits, pane working directories, and optionally
running processes) to a plain-text file. Restore brings everything
back exactly as it was. It works without a daemon — save and
restore are manual keystrokes.

Default save path: `~/.local/share/tmux/resurrect/`

Requires TPM (day-27 prerequisite).

## Task

### Part 1 — add the plugin

Add to `~/.tmux.conf` before the `run '~/.tmux/plugins/tpm/tpm'`
line:

```text
set -g @plugin 'tmux-plugins/tmux-resurrect'
```

Reload and install:

```text
Ctrl-b r
Ctrl-b I
```

### Part 2 — save a session

Open 2–3 windows with meaningful names and running processes
(e.g. `vim`, `htop`, a long `tail -f`). Save with:

```text
Ctrl-b Ctrl-s
```

tmux-resurrect prints a brief confirmation in the status bar.

### Part 3 — inspect the save file

List recent saves:

```bash
ls -lt ~/.local/share/tmux/resurrect/
```

View the last save — it is a plain-text, human-readable file:

```bash
cat ~/.local/share/tmux/resurrect/last
```

Each line records one pane: session name, window index, pane
index, working directory, and running command.

### Part 4 — simulate a restart

Kill the server and start a fresh session:

```bash
tmux kill-server
tmux new-session -s restored
```

### Part 5 — restore

Inside the fresh session:

```text
Ctrl-b Ctrl-r
```

All saved sessions, windows, and pane splits reappear.

### Part 6 — restore programs

By default resurrect restores layout but not running programs.
Enable restoration for common tools:

```text
set -g @resurrect-processes 'vim nvim htop ssh'
```

Reload (`Ctrl-b r`) and save again (`Ctrl-b Ctrl-s`) to include
running processes in the next snapshot.

## Completion goal

1. Save a session with at least 2 windows.
2. Kill the server, start fresh, restore with `Ctrl-b Ctrl-r`.
3. Confirm all windows and pane splits are back.

## Check

```text
file_exists    ~/.local/share/tmux/resurrect/last
file_contains  ~/.tmux.conf tmux-resurrect
```

---

## Workflow

1. Read this exercise, then practise the commands in tmux.
2. Run `tmux-trainer check` to verify your work.
3. Run `tmux-trainer done` when finished.
4. Run `tmux-trainer skip` to defer to another day.
