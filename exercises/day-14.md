# Day 14 — Copy Mode II: Yank and Paste

Goal: Copy text from the terminal without touching
the mouse.

## Task

Enable vi copy-mode keys in `~/.tmux.conf`:

```text
setw -g mode-keys vi
```

Reload config (`Ctrl-b r`), then enter copy mode:

```text
Ctrl-b [
```

Navigate to the text you want. Start selection:

```text
v        begin selection (vi mode)
V        select entire line
Ctrl-v   block / rectangle selection
```

Yank (copy) the selection:

```text
y        yank and exit copy mode
```

Paste inside tmux:

```text
Ctrl-b ]
```

Generate some output to practice on:

```bash
ls -la ~
```

## Completion goal

Copy a filename from `ls -la ~` output and paste it
into a new command without using the mouse.
