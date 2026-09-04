# Day 13 — Target Syntax

Goal: Address any pane in any window in any session
precisely using tmux target notation.

## Task

The target format is:

```text
session:window.pane
```

Examples:

```bash
# send a command to a specific pane without being inside it
tmux send-keys -t "work:shell.0" "ls -la" Enter

# check the content of a pane
tmux capture-pane -t "work:shell.0" -p | tail -20

# resize a specific pane
tmux resize-pane -t "work:shell.0" -D 5

# focus a specific pane
tmux select-pane -t "work:shell.0"
```

Shorthand rules:

```text
:window.pane     current session
window.pane      current session, named window
.pane            current window
```

## Completion goal

Create two sessions with two windows each, then use
`tmux send-keys -t` to run `date` in a specific pane
in the other session — without switching to it.
