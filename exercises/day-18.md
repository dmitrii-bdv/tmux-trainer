# Day 18 — Manual Session Snapshot

Goal: Understand how to save and restore your workspace
manually — the concept behind tools like tmux-resurrect.

## Task

List every open session, window, and pane:

```bash
tmux list-sessions
tmux list-windows -a
tmux list-panes  -a
```

Save the layout of a session to a file:

```bash
tmux list-windows -t training -F \
  "#{window_index} #{window_name} #{window_layout}" \
  > /tmp/tmux-snapshot.txt
cat /tmp/tmux-snapshot.txt
```

Kill and recreate a session from scratch using the
info you captured:

```bash
tmux new-session -d -s restored -n shell
tmux new-window  -t restored -n kube
tmux new-window  -t restored -n logs
tmux attach -t restored
```

## Completion goal

Save a snapshot of one session, kill it, and rebuild it
manually from the snapshot file — no copy-paste from
history.
