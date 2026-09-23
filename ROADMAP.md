# Roadmap

Ordered highest → lowest learning impact.
Pick from the top — earlier items unlock later ones.

Effort: [S] hours · [M] days · [L] week+

---

## Tier 4 — Content and curriculum expansion

### 17. Plugin-aware exercises (weeks 5–6) [M]

Add 10 exercises covering tmux-resurrect (session save/restore
across reboots), tmux-continuum (auto-save), and tmux-fingers
(fast on-screen copy hints). No comparable exercises exist in
any other learn-tmux repo found.

---

## Tier 5 — Polish and infrastructure

### 22. Webhook reminder [M]

Read `WEBHOOK_URL` from `~/.config/tmux-trainer/conf`. When set,
POST today's exercise title and goal alongside the macOS
notification. Planned platforms: Slack, Discord, Telegram.

### 23. Homebrew formula [L]

Package as a Homebrew formula for `brew install tmux-trainer`.
Significant ongoing maintenance cost; only worth pursuing once
the project has external users.
