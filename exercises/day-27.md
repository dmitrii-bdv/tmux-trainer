# Day 27 — Catppuccin Theme via TPM

Goal: Install TPM and the Catppuccin plugin to get a cohesive
tags: config status-bar plugins
colour theme and styled status modules with zero manual colour
codes.

## Target

```text
╭ 1 zsh ╮ ╭ 2 nvim ╮       ~/git/foo   tmux-dev   17:52
```

## Background — TPM plugin lifecycle

TPM (Tmux Plugin Manager) manages plugins declared in
`~/.tmux.conf`. The lifecycle is:

```text
1. Declare   set -g @plugin 'owner/repo' in tmux.conf
2. Install   Ctrl-b I  (capital i) — clones all new plugins
3. Reload    Ctrl-b r  — applies plugin configuration
4. Update    Ctrl-b U  — pulls latest for all plugins
5. Remove    delete the @plugin line, then Ctrl-b alt-u
```

Plugins live in `~/.tmux/plugins/`. TPM itself is just another
plugin cloned there first.

## Task

### Part 1 — install TPM

Clone TPM into the plugins directory:

```bash
git clone https://github.com/tmux-plugins/tpm \
  ~/.tmux/plugins/tpm
```

Verify:

```bash
ls ~/.tmux/plugins/tpm/tpm
```

### Part 2 — declare plugins in tmux.conf

Add the following block to `~/.tmux.conf`. It must go near the
top, before your status-bar options, so Catppuccin's defaults
load before you override anything:

```text
# ── plugins ───────────────────────────────────────────────────
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'catppuccin/tmux'
```

Add the Catppuccin flavor. Choose one:

```text
# latte (light)  frappe  macchiato  mocha (dark, default)
set -g @catppuccin_flavor 'mocha'
```

Wire up the right-side status modules — these replace
`status-right` entirely when Catppuccin is active:

```text
set -g @catppuccin_status_modules_right \
  "directory application session date_time"
```

Add the TPM bootstrap line at the very bottom of
`~/.tmux.conf` — it must be the last line:

```text
# Initialize TPM (keep this at the very bottom)
run '~/.tmux/plugins/tpm/tpm'
```

### Part 3 — install the plugin

Reload your config to pick up the new TPM bootstrap:

```text
Ctrl-b r
```

Then install all declared plugins:

```text
Ctrl-b I
```

TPM clones each plugin and prints a summary. Press any key to
dismiss. The Catppuccin theme should apply immediately.

### Part 4 — inspect and tune

List installed plugins:

```bash
ls ~/.tmux/plugins/
```

Check what modules are available:

```bash
ls ~/.tmux/plugins/tmux/status/
```

Swap flavors live to preview without restarting:

```bash
tmux set -g @catppuccin_flavor 'latte' \; run '~/.tmux/plugins/tpm/tpm'
```

Revert by reloading your config (`Ctrl-b r`).

Try reordering the status modules — for example, put `session`
first so it is closest to the window list:

```text
set -g @catppuccin_status_modules_right \
  "session directory date_time"
```

### Part 5 — combine with your day-26 settings

Catppuccin sets its own `status-left`, `status-right`, and window
formats. Your day-26 overrides for `status-left` and
`status-right` will conflict — comment them out and let
Catppuccin own the bar:

```text
# day-26 overrides (commented out — Catppuccin owns these now)
# set -g status-left " #{session_name}  "
# set -g status-right " #{b:pane_current_path} | %H:%M "
```

You can still keep `default-terminal`, `status-interval`,
`status-left-length`, and `status-right-length` — Catppuccin
respects those.

## Completion goal

1. Run `Ctrl-b I` and confirm TPM reports all plugins installed.
2. Verify the Catppuccin status bar is visible with at least the
   `session` and `date_time` modules.
3. Run `ls ~/.tmux/plugins/` and confirm both `tpm` and `tmux`
   (Catppuccin) directories exist.

## Check

```text
file_exists    ~/.tmux/plugins/tpm/tpm
file_contains  ~/.tmux.conf @catppuccin_flavor
file_contains  ~/.tmux.conf run '~/.tmux/plugins/tpm/tpm'
```

---

## Workflow

1. Read this exercise, then practise the commands in tmux.
2. Run `tmux-trainer check` to verify your work.
3. Run `tmux-trainer done` when finished.
4. Run `tmux-trainer skip` to defer to another day.
