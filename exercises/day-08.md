# Day 8 — Multiple Sessions

Goal: Switch between multiple tmux sessions the way you switch
between browser tabs — without leaving tmux.
tags: sessions navigation

## Task

Create three sessions:

```bash
tmux new -s work
tmux new -s infra
tmux new -s notes
```

Useful shortcuts from inside tmux:

```text
Ctrl-b s          session tree (interactive picker)
Ctrl-b (          switch to previous session
Ctrl-b )          switch to next session
Ctrl-b $          rename current session
Ctrl-b d          detach (leaves all sessions running)
```

From the shell:

```bash
tmux ls
tmux switch -t infra
tmux attach -t notes
```

## Completion goal

Switch between all three sessions using only
`Ctrl-b s`, `Ctrl-b (`, and `Ctrl-b )` — no detach,
no shell commands.

## Check

```text
session_exists  work
session_exists  infra
session_exists  notes
```

---

## Workflow

1. Read this exercise, then practise the commands in tmux.
2. Run `tmux-trainer check` to verify your work.
3. Run `tmux-trainer done` when finished.
4. Run `tmux-trainer skip` to defer to another day.
