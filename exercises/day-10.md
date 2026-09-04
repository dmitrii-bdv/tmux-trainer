# Day 10 — tmux.conf Basics

Goal: Give tmux a configuration that fits your hands,
then reload it live without restarting anything.

## Task

Create or edit `~/.tmux.conf`:

```text
# increase scrollback
set -g history-limit 10000

# start window numbering from 1
set -g base-index 1
setw -g pane-base-index 1

# renumber windows when one is closed
set -g renumber-windows on

# enable mouse (scroll, click to select pane)
set -g mouse on

# reload config with Ctrl-b r
bind r source-file ~/.tmux.conf \; display "config reloaded"
```

Reload from inside a running session:

```text
Ctrl-b :source-file ~/.tmux.conf
```

Or with the new binding (after the first manual reload):

```text
Ctrl-b r
```

## Completion goal

Add the config above, reload it live inside a running
session, and confirm the reload message appears.
