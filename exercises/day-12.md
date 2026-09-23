# Day 12 — Scripted Layouts

Goal: Replace manual setup with a repeatable script that
tags: scripting layouts
builds your workspace in seconds.

## Task

Create `~/bin/dev-workspace` (or anywhere on your PATH):

```bash
#!/usr/bin/env bash
set -euo pipefail

SESSION="dev"

tmux kill-session -t "${SESSION}" 2>/dev/null || true

tmux new-session -d -s "${SESSION}" -n "editor"
tmux new-window  -t "${SESSION}" -n "shell"
tmux new-window  -t "${SESSION}" -n "git"

# split the git window: left = git log, right = git diff
tmux split-window -h -t "${SESSION}:git"
tmux send-keys -t "${SESSION}:git.0" "git log --oneline -20" Enter
tmux send-keys -t "${SESSION}:git.1" "git diff" Enter

tmux select-window -t "${SESSION}:editor"
tmux attach -t "${SESSION}"
```

Make it executable:

```bash
chmod +x ~/bin/dev-workspace
```

Run it:

```bash
~/bin/dev-workspace
```

## Completion goal

Run the script, verify all three windows and both panes
in the git window are set up, then kill the session and
run it again from scratch.

## Check

```text
session_exists  dev
window_named    dev editor
window_named    dev shell
window_named    dev git
pane_count      dev:git 2
```

---

## Workflow

1. Read this exercise, then practise the commands in tmux.
2. Run `tmux-trainer check` to verify your work.
3. Run `tmux-trainer done` when finished.
4. Run `tmux-trainer skip` to defer to another day.
