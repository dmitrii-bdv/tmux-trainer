# Day 22 — Side Panel

Goal: Add a narrow file-browser strip to an existing
window — the tmux equivalent of VS Code's Explorer.

## Task

### Part 1 — create the side panel

Create a session and immediately carve out a narrow
left strip. The trick is to split the full pane and
give the NEW pane most of the space, so the original
pane becomes the narrow one:

```bash
tmux new-session -d -s side -n work
tmux split-window -t side:work.0 -h -l 80%
```

Pane 0 is now the narrow left strip (~20%). Pane 1 is
the wide right area.

Start a file browser in pane 0. Use `lf` if available
(lightweight, keyboard-driven), otherwise `tree`:

```bash
tmux send-keys -t side:work.0 \
  'lf . 2>/dev/null || tree -C -L 2 .' Enter
```

Start a shell in pane 1 and attach:

```bash
tmux select-pane -t side:work.1
tmux attach -t side
```

### Part 2 — label panes with a border title

Show a label in each pane's border to make the layout
self-documenting. Add to `~/.tmux.conf`:

```text
set -g pane-border-status top
set -g pane-border-format ' #{pane_title} '
```

Reload:

```text
Ctrl-b r
```

Set a title on the files pane from inside tmux:

```text
Ctrl-b :select-pane -t side:work.0 -T "files"
Ctrl-b :select-pane -t side:work.1 -T "editor"
```

Or from a script:

```bash
tmux select-pane -t side:work.0 -T "files"
tmux select-pane -t side:work.1 -T "editor"
```

### Part 3 — prevent the side panel from being zoomed away

When you zoom a pane (`Ctrl-b z`) the side panel
disappears. That is intentional — zoom gives you the
full terminal for focused work. Press `Ctrl-b z` again
to restore the layout.

### Part 4 — fix the panel width

If you want the file tree to stay exactly 25 columns
regardless of terminal width, use a fixed column count:

```bash
tmux split-window -t side:work.0 -h -l 80%
tmux resize-pane  -t side:work.0 -x 25
```

## Completion goal

1. Build the two-pane layout with a narrow files strip
   on the left and a wide pane on the right.
2. Label both panes using `pane-border-status`.
3. Zoom the right pane, work for a moment, then restore
   the full layout — all without touching the mouse.
