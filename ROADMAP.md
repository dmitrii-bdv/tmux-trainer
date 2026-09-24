# Roadmap

Effort: [S] hours · [M] days · [L] week+

---

## Content

### tmux.conf fundamentals [S]

Before styling, teach the config management workflow itself:

- Where tmux looks for config (`~/.tmux.conf`, XDG path)
- How to inspect live option values: `tmux show-options -g`
- How to inspect keybindings: `tmux list-keys`
- Live reload without restarting: `source-file` vs kill-server
- How to test a single option inline: `tmux set-option -g ...`
- Reading error output when a config line fails (`tmux -f /dev/null`)
- Difference between global (`-g`), session, window, and pane scope

Goal: user can confidently edit, reload, introspect, and debug
their config without restarting tmux or losing sessions.

### tmux.conf style progression — three exercises [M]

Three new exercises building on top of the day-10 config baseline.
Each stands alone; users pick the track that fits their workflow.

**Exercise A — Minimal modern status bar [S]**

Extend the day-10 base with `default-terminal`, `status-interval`,
`status-position`, `status-left`/`status-right` showing session
name and current path, and styled active-window formatting.
No plugins required. Result:

```text
 dev   1:zsh   2:nvim   3:k9s        ~/git/platform | 17:52
```

**Exercise B — Catppuccin theme via TPM [S]**

Install TPM, add the Catppuccin plugin, set `@catppuccin_flavor`,
and wire up status-right modules (directory, application, session,
date/time). Teaches the plugin lifecycle: install → `Ctrl-b I` →
reload. Result:

```text
╭ 1 zsh ╮ ╭ 2 nvim ╮       ~/git/foo   tmux-dev   17:52
```

**Exercise C — DevOps dashboard status bar [M]**

Build a custom right-side bar with live shell commands: git branch,
AWS profile (`$AWS_PROFILE`), kubectl context, kubectl namespace,
and time. No plugins needed. Teaches `#(shell-command)` and
`status-interval`. Target layout:

```text
 dev   1:zsh   2:nvim   3:k9s
   main | AWS:prod | eks-prod | observability | 17:52
```

Final step layers Catppuccin colours on top of the DevOps bar —
style without a full framework.

### jq exercises — filter and transform JSON [M]

After tmux basics are complete, introduce `jq` as a natural next tool
for DevOps and shell workflows. Source exercises from
[dmitrii-bdv/jq](https://github.com/dmitrii-bdv/jq).

Planned exercise tracks:

**Exercise A — jq basics [S]**

Identity, field access (`.field`, `.[0]`), pipe (`|`), and `keys`.
Goal: user can extract a value from any JSON API response.

**Exercise B — Selecting and filtering [S]**

`select/1`, `map/1`, `arrays`, `objects`, `has/1`, `in/1`.
Goal: user can filter arrays and objects by predicate.

**Exercise C — Transforming output [S]**

`{key: .val}` object construction, `@base64`, `@csv`, `@tsv`,
`@json`, `@text`. Goal: user can reshape JSON into a target format.

**Exercise D — Real-world pipelines [M]**

Combine `jq` with `curl`, `aws`, `kubectl`, and `docker` output.
Examples: parse ECS task arns, extract pod names, iterate ECR tags.
Goal: user can slot `jq` into any shell pipeline without googling
the syntax each time.

### xargs exercises — build and run commands from input [M]

After jq, introduce `xargs` as the glue that turns pipeline output
into command arguments. Complements jq-based workflows naturally.

**Exercise A — xargs basics [S]**

Default behaviour (split on whitespace/newlines), `-n` (args per
call), `-I{}` (placeholder). Goal: user can pass `find` or `echo`
output as arguments to any command.

**Exercise B — Parallel execution [S]**

`-P <n>` for parallel workers, combining with `-n 1`.
Goal: user can fan out a slow command (e.g. `curl`, `aws`) across
many inputs without writing a loop.

**Exercise C — Safe handling of filenames [S]**

`-0` with `find -print0` / `printf '%s\0'` to handle spaces and
special characters. Goal: user never breaks on filenames with spaces.

**Exercise D — Real-world pipelines [M]**

Combine `xargs` with `jq`, `aws`, `kubectl`, `docker`, and `git`.
Examples: delete stale ECR images, run `kubectl describe` on a list
of pods, bulk-clone repos. Goal: user can replace slow sequential
shell loops with a single composable pipeline.

### Plugin-aware exercises [M]

Add exercises covering tmux-resurrect, tmux-continuum, and
tmux-fingers. No comparable exercises exist in any other
learn-tmux repo found.

---

## Infrastructure

### Webhook reminder [M]

Read `WEBHOOK_URL` from `~/.config/tmux-trainer/conf`. When set,
POST today's exercise title and goal alongside the notification.
Planned platforms: Slack, Discord, Telegram.

### Homebrew formula [L]

`brew install tmux-trainer`. Only worth pursuing once the project
has external users.
