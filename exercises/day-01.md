# Day 1 — Sessions

Goal: Build muscle memory for creating, detaching from, listing, and reattaching to tmux sessions.

## Task

Create a named session:

```bash
tmux new -s training
```

Inside it run:

```bash
date
pwd
whoami
```

Detach:

```text
Ctrl-b d
```

List sessions:

```bash
tmux ls
```

Reconnect:

```bash
tmux attach -t training
```

## Completion goal

Repeat this cycle three times without checking a cheat sheet:

```text
create → detach → list → attach
```
