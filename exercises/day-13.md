# Day 13 — Target Syntax

Goal: Address any pane in any window in any session
tags: navigation scripting
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

Create two sessions named `nav-a` and `nav-b`, each with two
windows. Then use `tmux send-keys -t nav-b:2` to run `date` in
the second window of `nav-b` — without switching to it.

## Check

```text
session_exists  nav-a
session_exists  nav-b
window_count    nav-a 2
window_count    nav-b 2
```

---

## Workflow

1. Read this exercise, then practise the commands in tmux.
2. Run `tmux-trainer check` to verify your work.
3. Run `tmux-trainer done` when finished.
4. Run `tmux-trainer skip` to defer to another day.
