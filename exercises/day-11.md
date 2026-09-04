# Day 11 — Status Bar

Goal: Make the tmux status bar show the information you
actually need.

## Task

Add to `~/.tmux.conf`:

```text
# position and colours
set -g status-position bottom
set -g status-bg colour235
set -g status-fg colour136

# left: session name
set -g status-left "[#S] "
set -g status-left-length 20

# right: user, host, time
set -g status-right "#(whoami)@#h  %H:%M  %d-%b"
set -g status-right-length 50

# highlight active window
setw -g window-status-current-style fg=colour166,bold
```

Reload:

```text
Ctrl-b r
```

Inspect the current values without editing the file:

```bash
tmux show-options -g status-right
tmux show-options -g status-bg
```

## Completion goal

Reload your config and confirm that the status bar shows
your session name on the left and `user@host HH:MM date`
on the right.
