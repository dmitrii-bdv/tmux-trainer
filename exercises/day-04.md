# Day 4 — Debugging Workspace

Goal: Use tmux as a real debugging workspace rather than as a terminal toy.
tags: sessions windows workflow

## Task

Create a session:

```bash
tmux new -s debug
```

Create windows named:

```text
kube
aws
logs
```

Suggested commands:

### kube

```bash
kubectl get pods -A
```

### aws

```bash
aws sts get-caller-identity
```

### logs

Use any live log stream you currently need.

Practice:

```text
Ctrl-b n
Ctrl-b p
Ctrl-b w
Ctrl-b z
```

## Completion goal

Spend at least ten minutes working entirely inside the `debug` tmux session.

## Check

```text
session_exists  debug
window_named    debug kube
window_named    debug aws
window_named    debug logs
```

---

## Workflow

1. Read this exercise, then practise the commands in tmux.
2. Run `tmux-trainer check` to verify your work.
3. Run `tmux-trainer done` when finished.
4. Run `tmux-trainer skip` to defer to another day.
