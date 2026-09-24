# Day 25 — tmux.conf Workflow

Goal: Learn to edit, reload, introspect, and debug your tmux config
tags: config
without ever restarting tmux or losing your sessions.

## Where tmux looks for config

tmux reads the first file it finds, in this order:

```text
~/.tmux.conf
$XDG_CONFIG_HOME/tmux/tmux.conf   (usually ~/.config/tmux/tmux.conf)
/etc/tmux.conf
```

Check which file is active in your running session:

```bash
tmux display-message -p '#{config_files}'
```

## Task

### Part 1 — inspect your live config

List every global option tmux is currently running with:

```bash
tmux show-options -g
```

Read a single option's value:

```bash
tmux show-options -gv history-limit
tmux show-options -gv status-interval
```

List all active key bindings:

```bash
tmux list-keys
```

Filter to just your custom bindings (prefix `C-b` is default; yours
are anything added with `bind`):

```bash
tmux list-keys | grep -v "^bind-key.*C-b"
```

### Part 2 — set an option inline (no config edit needed)

Test an option without touching `~/.tmux.conf`:

```bash
tmux set-option -g status-position top
```

See it take effect immediately. Revert without reloading:

```bash
tmux set-option -g status-position bottom
```

Inline changes survive until tmux restarts or the option is
overwritten by a config reload.

### Part 3 — understand option scope

tmux has four scopes. The flag you pass determines which level you
set:

```text
-g       global  — applies to all sessions/windows/panes
(none)   session — current session only
-w       window  — current window only
-p       pane    — current pane only
```

Session-scoped options shadow global ones. Try:

```bash
tmux set-option status-position top      # this session only
tmux show-options    status-position     # session value
tmux show-options -g status-position     # global value (unchanged)
tmux set-option -u status-position       # unset session override
```

### Part 4 — edit and live-reload

Open `~/.tmux.conf` and raise the history limit:

```text
set -g history-limit 50000
```

Add a reload binding so you never have to type the full command:

```text
bind r source-file ~/.tmux.conf \; display "config reloaded"
```

Save the file, then reload from inside tmux:

```bash
tmux source-file ~/.tmux.conf
```

Or use the new binding: `Ctrl-b r`

Confirm the change took effect:

```bash
tmux show-options -gv history-limit
```

### Part 5 — debug a broken config

When a config line has a typo, tmux silently applies what it can
and skips the rest. To see all errors:

```bash
tmux -f ~/.tmux.conf new-session -d -s debug 2>&1 | head -20
tmux kill-session -t debug
```

To test a config in total isolation (no existing options, fresh
server):

```bash
tmux -f /dev/null new-session -d -s test 2>&1
tmux kill-session -t test
```

A blank `-f /dev/null` run with no errors means the problem is in
your config, not in tmux's defaults.

## Completion goal

1. Run `tmux show-options -gv history-limit` and confirm it prints
   `50000`.
2. Press `Ctrl-b r` and confirm the "config reloaded" message
   appears in the status bar.
3. Run `tmux list-keys | grep " r "` and confirm your reload
   binding is listed.

## Check

```text
option_set     history-limit 50000
file_contains  ~/.tmux.conf source-file
```

---

## Workflow

1. Read this exercise, then practise the commands in tmux.
2. Run `tmux-trainer check` to verify your work.
3. Run `tmux-trainer done` when finished.
4. Run `tmux-trainer skip` to defer to another day.
