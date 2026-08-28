# Day 4 — Debugging Workspace

Goal: Use tmux as a real debugging workspace rather than as a terminal toy.

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
