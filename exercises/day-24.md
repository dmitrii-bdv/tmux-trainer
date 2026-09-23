# Day 24 — Dev Workspace Setup

Goal: Build a scripted single-window tmux layout that
mirrors a VS Code project view — file tree on the left,
editor in the centre, two CLI panes stacked on the right
— and reproduce it in one command.

## Target layout

```text
┌──────┬──────────────────┬──────────┐
│      │                  │  cli 1   │
│files │     editor       ├──────────┤
│      │                  │  cli 2   │
└──────┴──────────────────┴──────────┘
 ~20%         ~55%            ~25%
```

All four areas are panes in a single window.
No mouse required to build or navigate it.

## Task

### Part 1 — build the layout by hand

Start a new detached session. The first pane covers the
full window — this will become the file tree:

```bash
tmux new-session -d -s myapp -n dev
```

Split right. The new pane (pane 1) takes 80% of the
width; the original narrow strip (pane 0) becomes the
file tree:

```bash
tmux split-window -t myapp:dev.0 -h -l 80%
```

Split pane 1 right again. The new pane (pane 2) takes
30% of pane 1's width and will hold the two CLI panes;
pane 1 shrinks to become the editor:

```bash
tmux split-window -t myapp:dev.1 -h -l 30%
```

Split pane 2 vertically to get the two stacked CLI
panes:

```bash
tmux split-window -t myapp:dev.2 -v
```

The pane map is now:

```text
pane 0  files (left strip)
pane 1  editor (centre)
pane 2  cli 1 (top right)
pane 3  cli 2 (bottom right)
```

Start a file browser in the left pane. Use `lf` if
installed, otherwise fall back to `tree`:

```bash
tmux send-keys -t myapp:dev.0 'lf .' Enter
# or: tmux send-keys -t myapp:dev.0 'tree -C .' Enter
```

Open your editor in the centre pane:

```bash
tmux send-keys -t myapp:dev.1 '$EDITOR .' Enter
```

Focus the editor pane, then attach:

```bash
tmux select-pane -t myapp:dev.1
tmux attach -t myapp
```

Navigate between panes:

```text
Ctrl-b q          show pane numbers, type number to jump
Ctrl-b ←/→/↑/↓   move between panes by direction
Ctrl-b z          zoom current pane full-screen (toggle)
```

### Part 2 — write a reusable setup script

Create `~/bin/dev-session`:

```bash
#!/usr/bin/env bash
# Usage: dev-session [session-name] [project-dir]
set -euo pipefail

SESSION="${1:-dev}"
DIR="${2:-$PWD}"

if tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux attach -t "$SESSION"
  exit 0
fi

tmux new-session  -d -s "$SESSION" -n dev -c "$DIR"

# pane 0: files (narrow left strip, ~20%)
tmux split-window -t "$SESSION:dev.0" -h -l 80% -c "$DIR"

# pane 1: editor (centre, ~55%)
# pane 2: cli area (right ~25%)
tmux split-window -t "$SESSION:dev.1" -h -l 30% -c "$DIR"

# pane 2: cli 1 (top right)
# pane 3: cli 2 (bottom right)
tmux split-window -t "$SESSION:dev.2" -v -c "$DIR"

# seed the panes
tmux send-keys -t "$SESSION:dev.0" 'lf . 2>/dev/null || tree -C .' Enter
tmux send-keys -t "$SESSION:dev.1" '$EDITOR .' Enter

# focus editor
tmux select-pane -t "$SESSION:dev.1"
tmux attach      -t "$SESSION"
```

Make it executable and run it:

```bash
chmod +x ~/bin/dev-session
dev-session myapp ~/projects/myapp
```

### Part 3 — per-project commands

Drop a `.tmux-session` file into any project root:

```bash
# .tmux-session
CLI1_CMD="npm run dev"
CLI2_CMD="npm test -- --watch"
```

Extend the script to source it and seed the CLI panes:

```bash
[[ -f "$DIR/.tmux-session" ]] && source "$DIR/.tmux-session"
tmux send-keys -t "$SESSION:dev.2" "${CLI1_CMD:-}" Enter
tmux send-keys -t "$SESSION:dev.3" "${CLI2_CMD:-}" Enter
```

Typical `CLI1_CMD` / `CLI2_CMD` pairs:

```text
npm run dev          /  npm test -- --watch
go run ./...         /  go test ./...
kubectl get pods -w  /  stern app-name
tail -f app.log      /  watch kubectl rollout status
```

## Completion goal

1. Run `dev-session myapp ~/projects/myapp` and verify
   the four-pane layout matches the diagram above.
2. Kill the session, run `dev-session myapp` again, and
   confirm it re-attaches without creating duplicates.
3. Add `.tmux-session` to a project with two commands
   and confirm both CLI panes start automatically.

## Check

```text
session_exists  myapp
pane_count      myapp:dev 4
```

---

## Workflow

1. Read this exercise, then practise the commands in tmux.
2. Run `tmux-trainer check` to verify your work.
3. Run `tmux-trainer done` when finished.
4. Run `tmux-trainer skip` to defer to another day.
