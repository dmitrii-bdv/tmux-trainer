# Day 41 — Live Weather Panel with wttr.in

Goal: Embed a live weather panel in your tmux layout using wttr.in,
tags: panes layouts
then recover it after it goes stale and extend it to show multiple
cities.

## Background

[wttr.in](https://github.com/chubin/wttr.in) is a curl-friendly
weather service. Running `curl wttr.in` in a pane prints a compact
weather report. The pane "dies" once curl exits — making this a
natural exercise in the full pane lifecycle: create → run → die →
recover.

Useful wttr.in formats:

```text
curl wttr.in              # full 3-day report (wide)
curl 'wttr.in/?0'         # current conditions only (compact)
curl 'wttr.in/Berlin'     # specific city, full report
curl 'wttr.in/Berlin?0'   # specific city, compact
```

## Task

### Part 1 — create the weather pane

Split off a narrow pane on the right and run wttr.in in it:

```bash
tmux split-window -h -l 40 'curl -s "wttr.in/?0"; echo; read -r'
```

`-l 40` sets the pane width to 40 columns. `read -r` keeps the
pane alive after curl exits so you can read the output.

### Part 2 — watch the pane die

Remove `read -r` to see the pane close as soon as curl finishes:

```bash
tmux split-window -h -l 40 'curl -s "wttr.in/?0"'
```

The pane disappears immediately — this is the dead-pane state.
Understanding it is the prerequisite for recovery.

### Part 3 — recover a dead pane

If the pane is open but blank (process exited), respawn it in
place without splitting again:

```bash
tmux respawn-pane -k -t '{right}' 'curl -s "wttr.in/?0"; read -r'
```

`-k` kills any existing process first. `-t '{right}'` targets
the rightmost pane in the current window.

### Part 4 — bind a recovery key

Add to `~/.tmux.conf`:

```text
bind W split-window -h -l 40 'curl -s "wttr.in/?0"; read -r'
```

Reload (`Ctrl-b r`). Now `Ctrl-b W` opens or reopens the weather
pane from anywhere, regardless of pane state.

### Part 5 — multi-city layout

Split the right column into sub-panes, one per city. Run this
from a shell pane:

```bash
CITIES=(Berlin Tokyo "New York")
tmux split-window -h -l 60
for city in "${CITIES[@]}"; do
  tmux split-window -v \
    "curl -s \"wttr.in/${city// /+}?0\"; read -r"
done
tmux select-layout -t '{right}' even-vertical
```

Spaces in city names become `+` (`New York` → `New+York`).
`select-layout even-vertical` distributes the sub-panes evenly.

### Part 6 — persistent multi-city keybind

Replace the single-city bind from Part 4 with a two-city version.
Edit `~/.tmux.conf` (substitute your own cities):

```text
bind W run-shell '\
  tmux split-window -h -l 60 \
    "curl -s wttr.in/Berlin?0; read -r"; \
  tmux split-window -v \
    "curl -s wttr.in/Tokyo?0; read -r"; \
  tmux select-layout even-vertical'
```

Reload (`Ctrl-b r`) and press `Ctrl-b W` to open both panes at
once. Press `Ctrl-b W` again after closing them to recreate the
layout.

## Completion goal

1. Open a weather pane with `Ctrl-b W` and confirm it shows
   current conditions.
2. Close and reopen — confirm the keybind recreates it cleanly.
3. Extend to two cities and verify both appear in separate
   sub-panes with `tmux select-layout even-vertical`.

## Check

```text
file_contains  ~/.tmux.conf wttr.in
```

---

## Workflow

1. Read this exercise, then practise the commands in tmux.
2. Run `tmux-trainer check` to verify your work.
3. Run `tmux-trainer done` when finished.
4. Run `tmux-trainer skip` to defer to another day.
