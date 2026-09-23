# Day 2 — Windows

Goal: Navigate a multi-window tmux workspace without using the mouse.

## Task

Inside your training session create four windows:

```text
shell
kubernetes
terraform
logs
```

Useful shortcuts:

```text
Ctrl-b c       new window
Ctrl-b ,       rename window
Ctrl-b n       next window
Ctrl-b p       previous window
Ctrl-b 0..9    select by number
Ctrl-b w       window selector
```

## Completion goal

Move through all four windows twice without using iTerm2 tabs or the mouse.

## Check

```text
session_exists  training
window_count    training 4
window_named    training shell
window_named    training kubernetes
window_named    training terraform
window_named    training logs
```

---

## Workflow

1. Read this exercise, then practise the commands in tmux.
2. Run `tmux-trainer check` to verify your work.
3. Run `tmux-trainer done` when finished.
4. Run `tmux-trainer skip` to defer to another day.
