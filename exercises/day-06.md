# Day 6 — Pane Layouts

Goal: Cycle through built-in pane layouts instead of
arranging panes by hand.

## Task

Create a session with three panes:

```bash
tmux new -s layouts
```

Split twice:

```text
Ctrl-b %
Ctrl-b "
```

Then cycle through every built-in layout preset with:

```text
Ctrl-b Space
```

The five presets are:

```text
even-horizontal
even-vertical
main-horizontal
main-vertical
tiled
```

You can also apply a specific layout from the command line:

```bash
tmux select-layout -t layouts even-horizontal
tmux select-layout -t layouts tiled
```

## Completion goal

Cycle through all five layouts at least twice without
touching the mouse or resizing panes manually.

## Check

```text
session_exists  layouts
pane_count      layouts 3
```

---

## Workflow

1. Read this exercise, then practise the commands in tmux.
2. Run `tmux-trainer check` to verify your work.
3. Run `tmux-trainer done` when finished.
4. Run `tmux-trainer skip` to defer to another day.
