# Day 3 — Panes

Goal: Build a small Kubernetes-style dashboard using tmux panes.
tags: panes

## Task

Create three panes.

Useful shortcuts:

```text
Ctrl-b %       vertical split
Ctrl-b "       horizontal split
Ctrl-b arrows  move between panes
Ctrl-b z       zoom/unzoom pane
```

Suggested commands:

```bash
kubectl get nodes
```

```bash
kubectl get pods -A
```

```bash
watch kubectl get pods -A
```

If no Kubernetes cluster is available, replace them with:

```bash
watch date
```

```bash
top
```

```bash
git status
```

## Completion goal

Navigate through all panes and zoom each pane once without clicking.

## Check

```text
session_exists  training
pane_count      training 3
```

---

## Workflow

1. Read this exercise, then practise the commands in tmux.
2. Run `tmux-trainer check` to verify your work.
3. Run `tmux-trainer done` when finished.
4. Run `tmux-trainer skip` to defer to another day.
