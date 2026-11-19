# Roadmap

Effort: [S] hours · [M] days · [L] week+

---

## Next

1. **Reusable reminder workflow with channel variables** [M]
   — configure e-mail, Telegram, Slack, or Discord per repo through
   GitHub variables and secrets; see
   `docs/administration/github-workflow.md`.
2. **Telegram integration** [M]
3. **Slack integration** [M]
4. **Discord integration** [M]

---

## Ideas

### Homebrew formula [L]

`brew install tmux-trainer`. Only worth pursuing once the project
has external users.

### Website version [L]

A browser version of tmux-trainer with the same exercises and an
emulated tmux terminal, so people can practise without installing
anything. Planned for some time in the future; no timeline yet. The
CLI stays the primary product until then.

---

## Completed

### Content

- **tmux.conf fundamentals** [S] → day-29
- **Status bar progression** [M] → days 26-28
  (minimal modern, Catppuccin via TPM, DevOps dashboard)
- **jq exercises** (A–D) [M] → days 30-33
- **xargs exercises** (A–D) [M] → days 34-37
- **Plugin-aware exercises** [M] → days 38-40
  (tmux-resurrect, tmux-continuum, tmux-fingers)
- **wttr.in weather panel** [S] → day-41
  (pane lifecycle, recovery keybind, multi-city extension)

### Infrastructure

- **Webhook reminder** [M] — POSTs exercise title and goal to
  Telegram, Slack, or Discord on every run; platform detected
  from URL shape.
