# Day 8 — Multiple Sessions

Goal: Switch between multiple tmux sessions the way you
switch between browser tabs — without leaving tmux.

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
