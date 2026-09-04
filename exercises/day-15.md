# Day 15 — Capture Pane Output

Goal: Save and inspect what a pane printed — useful for
capturing the output of a long-running process after
the fact.

## Task

Run something in a pane:

```bash
for i in $(seq 1 20); do echo "event $i at $(date +%T)"; sleep 0.1; done
```

Capture the pane's visible content to stdout:

```bash
tmux capture-pane -t 0 -p
```

Capture the full scrollback buffer to a file:

```bash
tmux capture-pane -t 0 -p -S - > /tmp/pane-dump.txt
cat /tmp/pane-dump.txt
```

Pipe pane output live to a file (starts logging from now):

```text
Ctrl-b :pipe-pane -o 'cat >> /tmp/tmux-live.log'
```

Stop piping:

```text
Ctrl-b :pipe-pane
```

## Completion goal

Run the loop, capture the full scrollback to a file,
and verify all 20 lines are present in the file.
