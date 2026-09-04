# Day 19 — Live Config Reload

Goal: Iterate on your tmux configuration and apply
changes without restarting sessions or losing state.

## Task

Add a reload binding if you have not already done so
(from Day 10):

```text
bind r source-file ~/.tmux.conf \; display "config reloaded"
```

Practice the live reload loop:

1. Edit `~/.tmux.conf` (change a colour, tweak the
   status bar, add a binding).
2. Reload from inside tmux:

```text
Ctrl-b r
```

1. Verify the change took effect immediately.

Useful commands for inspecting current config:

```bash
tmux show-options -g               # all global options
tmux show-options -g status-right  # one option
tmux show-window-options -g        # window options
tmux list-keys                     # all key bindings
```

## Completion goal

Make three distinct config changes, reload after each
one, and verify each change without restarting any
session.
