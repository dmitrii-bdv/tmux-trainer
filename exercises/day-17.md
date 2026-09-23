# Day 17 — AWS / Terraform Workspace

Goal: Build a dedicated debugging session for cloud
infrastructure work — no more switching between random
tabs.

## Task

Create the session from the command line:

```bash
SESSION="cloud"

tmux new-session -d -s "${SESSION}" -n "aws"
tmux new-window -t "${SESSION}" -n "tf"
tmux new-window -t "${SESSION}" -n "logs"

# aws: identity + region at a glance
tmux send-keys -t "${SESSION}:aws" \
  "aws sts get-caller-identity && echo Region: \${AWS_REGION}" Enter

# tf: ready to plan
tmux send-keys -t "${SESSION}:tf" "terraform init 2>&1 | tail -5" Enter

# logs: watch CloudWatch or local log file
tmux send-keys -t "${SESSION}:logs" "watch -n5 date" Enter

tmux select-window -t "${SESSION}:aws"
tmux attach -t "${SESSION}"
```

Practice switching rapidly:

```text
Ctrl-b n   next window
Ctrl-b p   previous window
Ctrl-b w   interactive window list
```

## Completion goal

Spend ten minutes doing real AWS or Terraform work
entirely inside this session without opening a new
terminal tab.

## Check

```text
session_exists  cloud
window_named    cloud aws
window_named    cloud tf
window_named    cloud logs
```

---

## Workflow

1. Read this exercise, then practise the commands in tmux.
2. Run `tmux-trainer check` to verify your work.
3. Run `tmux-trainer done` when finished.
4. Run `tmux-trainer skip` to defer to another day.
