# Day 20 — Final Drill: SRE Workspace

Goal: Build a complete SRE workspace from scratch,
from memory, in under five minutes.

## Task

No copy-paste. No notes. No cheat sheet.

Build this layout:

```text
Session: sre-final
  Window 1: kube      — kubectl get pods -A (watch)
  Window 2: aws       — aws sts get-caller-identity
  Window 3: tf        — terraform show (or echo "no tf here")
  Window 4: logs      — two panes side by side
    pane 0: watch date
    pane 1: tail -f /var/log/system.log (or top)
```

Requirements:

- All windows and panes created via keyboard shortcuts
  or a single shell script — no mouse.
- Status bar shows session name, hostname, and time.
- Config reloaded live at least once during the drill.
- Switch between all windows using `Ctrl-b w` at the
  end to confirm the layout.

## Completion goal

Finish the full layout in under five minutes. If it
takes longer, note which steps slowed you down and
repeat tomorrow.

## Check

```text
session_exists  sre-final
window_named    sre-final kube
window_named    sre-final aws
window_named    sre-final tf
window_named    sre-final logs
pane_count      sre-final:logs 2
```

---

## Workflow

1. Read this exercise, then practise the commands in tmux.
2. Run `tmux-trainer check` to verify your work.
3. Run `tmux-trainer done` when finished.
4. Run `tmux-trainer skip` to defer to another day.
