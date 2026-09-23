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

## Check

Run this before the final `tmux kill-session` cleanup step.

```text
session_exists  recovery-test
pane_running    recovery-test watch
```

---

## Workflow

1. Read this exercise, then practise the commands in tmux.
2. Run `tmux-trainer check` to verify your work.
3. Run `tmux-trainer done` when finished.
4. Run `tmux-trainer skip` to defer to another day.
