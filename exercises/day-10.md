# Day 10 — tmux.conf Basics

Goal: Give tmux a configuration that fits your hands,
tags: config
then reload it live without restarting anything.

## Task

Create or edit `~/.tmux.conf`:

```text
# increase scrollback
set -g history-limit 10000

# start window numbering from 1
set -g base-index 1
setw -g pane-base-index 1

# renumber windows when one is closed
set -g renumber-windows on

# enable mouse (scroll, click to select pane)
set -g mouse on

# reload config with Ctrl-b r
bind r source-file ~/.tmux.conf \; display "config reloaded"
```

Reload from inside a running session:

```text
Ctrl-b :source-file ~/.tmux.conf
```

Or with the new binding (after the first manual reload):

```text
Ctrl-b r
```

Show pane titles in the border — add these lines to `~/.tmux.conf`:

```text
# show pane title in the top border
set -g pane-border-status top
set -g pane-border-format ' #{pane_title} '
```

Reload again (`Ctrl-b r`) and observe the title bar appear above
each pane. Rename the current pane's title:

```bash
printf '\033]2;%s\033\\' "my-pane"
```

Most programs (vim, htop, shells) set the title automatically
once `pane-border-status` is on.

## Completion goal

Add all config lines above, reload live, confirm the reload
message appears, and verify the pane title bar is visible.

## Check

```text
option_set  history-limit 10000
option_set  mouse on
option_set  pane-border-status top
```

---

## Workflow

1. Read this exercise, then practise the commands in tmux.
2. Run `tmux-trainer check` to verify your work.
3. Run `tmux-trainer done` when finished.
4. Run `tmux-trainer skip` to defer to another day.
