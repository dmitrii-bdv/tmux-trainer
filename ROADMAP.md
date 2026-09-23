# Roadmap

Effort: [S] hours · [M] days · [L] week+

---

## Content

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
