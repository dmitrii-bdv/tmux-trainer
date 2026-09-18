# Day 21 — Sized Splits

Goal: Control exact pane proportions instead of relying
on tmux defaults — the prerequisite for building
structured layouts.

## Task

### Part 1 — split with a percentage

Create a session and split it vertically, giving the new
right pane 70% of the window width:

```bash
tmux new-session -d -s sizes -n demo
tmux split-window -t sizes:demo -h -l 70%
tmux attach -t sizes
```

The original pane (left) now holds 30%, the new pane
(right) holds 70%.

Try the opposite — a narrow right strip:

```text
Ctrl-b :split-window -h -l 20%
```

### Part 2 — split with a fixed column/line count

Percentage sizes are relative. For a side panel that
stays the same width regardless of terminal size, use a
fixed column count:

```bash
tmux split-window -t sizes:demo -h -l 30
```

This gives the new pane exactly 30 columns regardless
of window width.

Compare the two approaches by resizing your terminal
while watching:

```text
# percentage version — right pane tracks terminal width
Ctrl-b :split-window -h -l 25%

# fixed version — right pane stays 30 columns
Ctrl-b :split-window -h -l 30
```

### Part 3 — resize after the fact

Resize any pane once it exists:

```text
Ctrl-b Alt-←/→     resize left/right by 5 columns
Ctrl-b Alt-↑/↓     resize up/down by 5 rows
```

Or from the command line (useful in scripts):

```bash
tmux resize-pane -t sizes:demo.0 -x 30
tmux resize-pane -t sizes:demo.1 -x 80
```

`-x` sets a pane's width in columns; `-y` sets its height
in rows.

### Part 4 — vertical split at the bottom

Split a pane horizontally at the bottom, giving the
lower strip 30% of the height:

```bash
tmux split-window -t sizes:demo.0 -v -l 30%
```

This produces a narrow scratch area at the bottom of
the left pane — the pattern used for an integrated
terminal in a dev layout.

## Completion goal

Build this layout from scratch using only percentage
and fixed-column splits — no manual resizing:

```text
┌────────────┬──────────────────────────┐
│            │                          │
│   ~20 col  │          ~70%            │
│            │                          │
└────────────┴──────────────────────────┘
```

Confirm both pane widths with:

```bash
tmux display-message -t sizes:demo.0 '#{pane_width}'
tmux display-message -t sizes:demo.1 '#{pane_width}'
```

## Check

```text
session_exists  sizes
pane_count      sizes:demo 3
```
