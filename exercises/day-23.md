# Day 23 — Asymmetric Layout Script

Goal: Script a precise multi-pane layout by targeting
specific pane indices — the skill that turns a one-off
setup into a repeatable command.

## Task

### Part 1 — understand the pane index sequence

When you chain splits, tmux assigns pane indices in
creation order. Knowing this lets you target exactly
the right pane at each step.

Trace through the sequence that builds the target layout:

```text
Step 0: new-session          → pane 0 (full window)
Step 1: split pane 0 -h 80%  → pane 0 (left 20%)
                               pane 1 (right 80%)
Step 2: split pane 1 -h 30%  → pane 0 (left 20%)
                               pane 1 (centre 56%)
                               pane 2 (right 24%)
Step 3: split pane 2 -v      → pane 0 (left 20%)
                               pane 1 (centre 56%)
                               pane 2 (top right 12% h)
                               pane 3 (bottom right 12% h)
```

Target layout:

```text
┌──────┬──────────────────┬──────────┐
│      │                  │  pane 2  │
│  p0  │      pane 1      ├──────────┤
│      │                  │  pane 3  │
└──────┴──────────────────┴──────────┘
```

### Part 2 — build it step by step

Run each command and verify the pane index after each
split:

```bash
tmux new-session  -d -s layout -n dev
tmux split-window -t layout:dev.0 -h -l 80%
tmux list-panes   -t layout:dev -F '#{pane_index} #{pane_width}x#{pane_height}'
```

```bash
tmux split-window -t layout:dev.1 -h -l 30%
tmux list-panes   -t layout:dev -F '#{pane_index} #{pane_width}x#{pane_height}'
```

```bash
tmux split-window -t layout:dev.2 -v
tmux list-panes   -t layout:dev -F '#{pane_index} #{pane_width}x#{pane_height}'
```

Attach and confirm visually:

```bash
tmux attach -t layout
```

### Part 3 — put it in a script

Create `~/bin/four-pane`:

```bash
#!/usr/bin/env bash
set -euo pipefail

SESSION="${1:-layout}"
DIR="${2:-$PWD}"

if tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux attach -t "$SESSION"
  exit 0
fi

tmux new-session  -d -s "$SESSION" -n dev -c "$DIR"
tmux split-window -t "$SESSION:dev.0" -h -l 80%  -c "$DIR"
tmux split-window -t "$SESSION:dev.1" -h -l 30%  -c "$DIR"
tmux split-window -t "$SESSION:dev.2" -v          -c "$DIR"

tmux select-pane -t "$SESSION:dev.1"
tmux attach      -t "$SESSION"
```

```bash
chmod +x ~/bin/four-pane
four-pane test ~/projects
```

### Part 4 — verify the layout is correct

After running the script, confirm each pane is where
you expect it:

```bash
tmux list-panes -t test:dev \
  -F '#{pane_index} #{pane_left},#{pane_top} #{pane_width}x#{pane_height}'
```

Expected: pane 0 has the smallest width (left strip),
pane 1 has the largest width (centre), panes 2 and 3
share the right column with equal height.

## Completion goal

1. Run the `four-pane` script and verify all four panes
   are in the correct positions using `list-panes`.
2. Kill the session and run `four-pane test` again —
   confirm it re-attaches instead of rebuilding.
3. Deliberately break the split sequence (e.g., target
   the wrong pane index) and observe how the layout
   changes — then fix it.

## Check

```text
session_exists  layout
pane_count      layout:dev 4
```
