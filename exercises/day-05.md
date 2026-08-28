# Day 5 — Recovery Drill

Goal: Prove to yourself why persistent tmux sessions are useful.

## Task

Create:

```bash
tmux new -s recovery-test
```

Run:

```bash
watch date
```

Close the iTerm2 window entirely.

Open iTerm2 again and run:

```bash
tmux ls
tmux attach -t recovery-test
```

The process should still be running.

Finally clean up:

```bash
tmux kill-session -t recovery-test
```

## Completion goal

Recover the running process after closing iTerm2 without restarting it.
