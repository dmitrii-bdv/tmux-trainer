# Day 26 — Minimal Modern Status Bar

Goal: Build a clean, plugin-free status bar using tmux format
tags: config status-bar
strings — session name on the left, path and time on the right,
styled active-window indicator in the middle.

## Target

```text
 dev   1:zsh   2:nvim   3:k9s          platform | 17:52
```

No plugins. No shell commands. Pure tmux format strings.

## Background — format strings

tmux expands `#{variable}` inside any format option. A few
useful ones for the status bar:

```text
#{session_name}      current session name
#{window_index}      window number  (same as #I)
#{window_name}       window name    (same as #W)
#{pane_current_path} full path of the focused pane
#{b:pane_current_path} basename only — last path component
#{host}              hostname       (same as #h)
%H:%M                strftime — hour:minute
%Y-%m-%d             strftime — ISO date
```

The `b:` modifier in `#{b:variable}` returns the basename, like
`basename` in a shell.

## Task

### Part 1 — true colour and refresh rate

Add to `~/.tmux.conf`:

```text
set -g default-terminal "tmux-256color"
set -g status-interval 5
```

`default-terminal` tells tmux which terminfo entry to use inside
panes. `tmux-256color` enables 256-colour and italic support
without requiring a plugin.

`status-interval` sets how often (in seconds) tmux re-evaluates
`status-right` and `status-left`. Default is 15 — 5 is snappier
for a path display that changes as you navigate.

### Part 2 — left and right segments

Replace the existing `status-left` / `status-right` lines (or
add them if absent):

```text
set -g status-left " #{session_name}  "
set -g status-left-length 30

set -g status-right " #{b:pane_current_path} | %H:%M "
set -g status-right-length 50
```

The leading and trailing spaces give breathing room.
`#{b:pane_current_path}` shows just the current directory name
(e.g. `platform`), not the full path — keeping the bar compact.

### Part 3 — window list formatting

By default windows show as `1:zsh 2:nvim`. Style them with
explicit format strings and highlight the active one:

```text
setw -g window-status-format         " #I:#W "
setw -g window-status-current-format " #I:#W "
setw -g window-status-current-style  bold
```

`window-status-current-style` accepts any combination of:

```text
bold  italics  underscore
fg=colourN  (0-255)
fg=colour214   # orange
fg=colour39    # sky blue
fg=colour82    # green
bg=colourN
```

Pick a colour that works with your terminal theme. A plain
`bold` already creates a clear visual separation.

### Part 4 — reload and inspect

Reload your config:

```text
Ctrl-b r
```

Inspect the live values to confirm they took effect:

```bash
tmux show-options -gv status-interval
tmux show-options -gv status-left
tmux show-options -gv status-right
tmux show-options -g  window-status-current-style
```

Open a few windows (`Ctrl-b c`) and navigate between them
(`Ctrl-b n`, `Ctrl-b p`) to see the active-window highlight
move.

### Part 5 — tweak the right segment

To show a longer path instead of just the basename, swap
`#{b:pane_current_path}` for `#{pane_current_path}`. The full
path won't collapse `~` — that requires a shell command (covered
in Day 28). For now, basename keeps the bar readable.

Experiment with the date alongside the time:

```text
set -g status-right " #{b:pane_current_path} | %d %b %H:%M "
```

## Completion goal

1. Reload and confirm the status bar matches the target layout.
2. Open three windows, navigate between them, and verify the
   active one appears bold (or coloured).
3. Run `tmux show-options -gv status-interval` and confirm `5`.

## Check

```text
option_set  status-interval 5
option_set  status-left-length 30
file_contains  ~/.tmux.conf window-status-current
```

---

## Workflow

1. Read this exercise, then practise the commands in tmux.
2. Run `tmux-trainer check` to verify your work.
3. Run `tmux-trainer done` when finished.
4. Run `tmux-trainer skip` to defer to another day.
