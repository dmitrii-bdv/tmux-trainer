# Day 29 — tmux.conf Fundamentals: Deeper Inspection

Goal: Go beyond basic reload — query every option scope, read
tags: config
server-level settings, filter the live key-binding tables, and
isolate errors to a specific config file without touching your
main session.

## Background — three option namespaces

tmux splits options into three namespaces. Each has its own
show command:

```text
show-options        session and global options  (-g for global)
show-window-options window options              (-g for global)
show-options -s     server options (shared across all sessions)
```

Server options like `escape-time` and `buffer-limit` are set
once per server process. They cannot be scoped per-session.

## Task

### Part 1 — confirm your active config file

```bash
tmux display-message -p '#{config_files}'
```

tmux searches in order and loads the first match:

```text
~/.tmux.conf
$XDG_CONFIG_HOME/tmux/tmux.conf  (~/.config/tmux/tmux.conf)
/etc/tmux.conf
```

To start a session with a custom file instead:

```bash
tmux -f /tmp/test.conf new-session -d -s probe
tmux kill-session -t probe
```

### Part 2 — query all three namespaces

Global session options (what `set -g` writes):

```bash
tmux show-options -g
tmux show-options -gv status-interval
tmux show-options -gv history-limit
```

Global window options (what `setw -g` writes):

```bash
tmux show-window-options -g
tmux show-window-options -gv window-status-format
```

Server options (shared, no `-g` needed):

```bash
tmux show-options -s
tmux show-options -sv escape-time
```

`show-options` reads the **live** state — not the file on disk.
An option you set inline with `set-option` appears here even if
the file was never edited.

### Part 3 — target a specific session, window, or pane

Every `show-options` and `set-option` accepts `-t target`:

```bash
tmux show-options -t dev          # session named "dev"
tmux show-options -t dev:1        # window 1 in session "dev"
tmux show-options -t dev:1.0      # pane 0 in that window
```

A session-scoped value shadows the global one. Unset it to
restore the global:

```bash
tmux set-option -t dev status-interval 60
tmux show-options    -t dev status-interval   # 60
tmux show-options -g     status-interval      # unchanged
tmux set-option -u  -t dev status-interval    # remove override
```

### Part 4 — filter the live key-binding tables

tmux organises bindings into named tables. The most important:

```text
prefix     bindings entered after Ctrl-b
root       bindings active without a prefix (e.g. mouse)
copy-mode-vi  bindings active inside vi copy mode
```

List all bindings in the prefix table:

```bash
tmux list-keys -T prefix
```

Find bindings that call `send-keys`:

```bash
tmux list-keys | grep send-keys
```

Find your reload binding from Day 25:

```bash
tmux list-keys -T prefix | grep source-file
```

`list-keys` shows the live table — a `bind-key` call you ran
inline appears immediately, before any config reload.

### Part 5 — read error output

tmux writes config errors to stderr of the process that started
the server. If you launched tmux from a terminal, errors appear
*in that terminal*, not inside any pane.

To capture them explicitly:

```bash
tmux -f ~/.tmux.conf new-session -d -s dbg 2>&1 | head -20
tmux kill-session -t dbg
```

To test a snippet in isolation without polluting your main
config:

```bash
cat > /tmp/test.conf <<'EOF'
set -g status-interval 99
set -g bad_option_name on
EOF
tmux -f /tmp/test.conf new-session -d -s probe 2>&1
tmux kill-session -t probe
```

The valid line applies; the bad line prints an error. If the
server is in a broken state, `tmux kill-server` forces a clean
restart — all sessions are lost, so use it only as a last resort.

## Completion goal

1. Run `tmux show-options -sv escape-time` and note the value.
2. Run `tmux list-keys -T prefix | grep source-file` and confirm
   your `Ctrl-b r` reload binding is listed.
3. Run `tmux -f /dev/null new-session -d -s test 2>&1` and
   confirm it exits with no output (clean default config),
   then `tmux kill-session -t test`.

## Check

```text
option_set  status-interval 5
```

---

## Workflow

1. Read this exercise, then practise the commands in tmux.
2. Run `tmux-trainer check` to verify your work.
3. Run `tmux-trainer done` when finished.
4. Run `tmux-trainer skip` to defer to another day.
