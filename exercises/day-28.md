# Day 28 — DevOps Dashboard Status Bar

Goal: Build a plugin-free status bar that shows live DevOps context —
tags: config status-bar scripting
git branch, AWS profile, kubectl context and namespace — using
`#(shell-command)` and `status-interval`.

## Target

```text
 dev   1:zsh   2:nvim   3:k9s
   main | AWS:prod | eks-prod | observability | 17:52
```

Two-line layout: window list on top, context strip on the bottom.
No plugins. Every field is a live shell command.

## Background — shell commands in the status bar

tmux evaluates `#(command)` inside format strings and caches the
result until the next `status-interval` tick. That makes it safe
to call slow commands (like `kubectl`) — they run in the background
and the bar updates when they finish.

```text
#(git -C #{pane_current_path} branch --show-current 2>/dev/null)
```

The `-C path` flag runs git against the focused pane's directory,
not the directory where tmux started.

Pipe to `cut`, `awk`, or `sed` when you need to trim output:

```text
#(kubectl config current-context 2>/dev/null | cut -d/ -f2)
```

## Task

### Part 1 — two-line layout

Enable the two-line status bar:

```text
set -g status 2
set -g status-format[0] \
  "#[align=left]#{status-left}#{W:#{E:window-status-format} ,\
#{E:window-status-current-format} }#{status-right}"
set -g status-format[1] \
  "#[align=centre] #(git -C #{pane_current_path} \
branch --show-current 2>/dev/null) \
| AWS:${AWS_PROFILE:-none} \
| #(kubectl config current-context 2>/dev/null | cut -d: -f2) \
| #(kubectl config view --minify \
--output 'jsonpath={..namespace}' 2>/dev/null) \
| %H:%M "
```

`set -g status 2` switches tmux to two status lines (indexed 0
and 1). Line 0 gets the existing window list; line 1 gets the
context strip.

### Part 2 — refresh rate

Set a short interval so the git branch updates as you `cd`:

```text
set -g status-interval 5
```

### Part 3 — reload and verify

Reload your config:

```text
Ctrl-b r
```

Open a terminal pane and `cd` into a git repo. Wait up to 5 seconds
for the branch name to appear in the bottom strip.

Inspect the live value to confirm evaluation is working:

```bash
tmux display-message -p \
  '#(git -C #{pane_current_path} branch --show-current 2>/dev/null)'
```

### Part 4 — style the context strip

Add colour to make the two lines visually distinct. Apply a style
to the second status line:

```text
set -g status-style         "bg=colour235,fg=colour250"
set -g status-format[1]     "#[bg=colour234,fg=colour244] \
#(git -C #{pane_current_path} branch --show-current 2>/dev/null) \
| AWS:${AWS_PROFILE:-none} \
| #(kubectl config current-context 2>/dev/null | cut -d: -f2) \
| #(kubectl config view --minify \
--output 'jsonpath={..namespace}' 2>/dev/null) \
| %H:%M "
```

`colour235` / `colour234` are dark greys; `colour244` is mid-grey.
Swap for any 256-colour value that suits your terminal theme.

### Part 5 — layer Catppuccin colours (optional)

If you completed Day 27 and have Catppuccin active, you can reuse
its palette variables in place of raw colour codes:

```text
set -g status-format[1] \
  "#[bg=#{@thm_surface_0},fg=#{@thm_subtext_1}] \
#(git -C #{pane_current_path} branch --show-current 2>/dev/null) \
| AWS:${AWS_PROFILE:-none} \
| #(kubectl config current-context 2>/dev/null | cut -d: -f2) \
| #(kubectl config view --minify \
--output 'jsonpath={..namespace}' 2>/dev/null) \
| %H:%M "
```

This keeps the context strip visually consistent with the
Catppuccin window list above it without a plugin.

### Part 6 — handle missing tools gracefully

If `kubectl` or `aws` is absent the bar should stay readable:

```text
#(command -v kubectl >/dev/null && \
  kubectl config current-context 2>/dev/null || echo "—")
```

Apply the same pattern to any field that depends on an optional CLI.

## Completion goal

1. Confirm two status lines appear after `Ctrl-b r`.
2. `cd` into a git repo and verify the branch name updates within
   5 seconds.
3. Run `tmux show-options -g status` and confirm the value is `2`.

## Check

```text
option_set  status-interval 5
file_contains  ~/.tmux.conf status-format[1]
file_contains  ~/.tmux.conf pane_current_path
```

---

## Workflow

1. Read this exercise, then practise the commands in tmux.
2. Run `tmux-trainer check` to verify your work.
3. Run `tmux-trainer done` when finished.
4. Run `tmux-trainer skip` to defer to another day.
