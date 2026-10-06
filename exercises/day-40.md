# Day 40 — Text Grabbing with tmux-fingers

Goal: Grab URLs, file paths, git hashes, and IP addresses from
tags: plugins
pane output without copy mode, using tmux-fingers hints.

## Background

tmux-fingers scans visible pane content for recognisable patterns
(URLs, paths, hashes, IPs, hex strings, UUIDs, numbers) and
overlays a single-letter hint on each match. Press the hint key
to copy the matched text to the clipboard and tmux paste buffer
— no mouse, no copy mode, no manual selection.

Built-in patterns: `http://`, `https://`, `git@` URLs; file
paths; git SHAs; IPv4 addresses; hex strings; UUIDs; numbers.

Requires TPM (day-27 prerequisite).

## Task

### Part 1 — add the plugin

```text
set -g @plugin 'Morantron/tmux-fingers'
```

Reload and install:

```text
Ctrl-b r
Ctrl-b I
```

### Part 2 — trigger fingers

The default binding is `Ctrl-b F` (capital F):

```text
Ctrl-b F
```

Pane content dims and each recognised pattern gets a coloured
hint letter. Press a hint letter to copy that match; press `Esc`
to cancel.

### Part 3 — grab a URL

Print a URL:

```bash
echo "Visit https://github.com/tmux/tmux for docs"
```

Press `Ctrl-b F`, then the hint letter next to the URL. The URL
is copied to the tmux paste buffer and the system clipboard.

### Part 4 — grab a file path

```bash
echo "Config at ~/.tmux.conf and ~/.config/tmux/tmux.conf"
```

Trigger fingers and grab one of the paths.

### Part 5 — paste grabbed text

After grabbing, paste from the tmux buffer:

```text
Ctrl-b ]
```

Or from the system clipboard: `Cmd-v` on macOS, `Ctrl-Shift-v`
in most Linux terminals.

### Part 6 — custom pattern

Add your own regex to catch additional patterns, e.g. Jira
ticket IDs:

```text
set -g @fingers-pattern-0 '[A-Z]+-[0-9]+'
```

Reload (`Ctrl-b r`) and test:

```bash
echo "Fix OBS-342 and PLAT-1001"
```

Trigger fingers — both ticket IDs should appear as hints.

### Part 7 — change the trigger key

If `F` conflicts with an existing binding, rebind:

```text
set -g @fingers-key 'g'
```

Reload to apply.

## Completion goal

1. Run `echo "https://github.com/tmux/tmux"` and grab the URL
   with tmux-fingers.
2. Paste it into a new pane and confirm it matches exactly.

## Check

```text
file_exists    ~/.tmux/plugins/tmux-fingers
file_contains  ~/.tmux.conf tmux-fingers
```

---

## Workflow

1. Read this exercise, then practise the commands in tmux.
2. Run `tmux-trainer check` to verify your work.
3. Run `tmux-trainer done` when finished.
4. Run `tmux-trainer skip` to defer to another day.
