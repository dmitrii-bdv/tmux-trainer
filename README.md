# tmux-trainer

Learn tmux by doing — one short exercise each working day,
delivered as a macOS notification at 09:00.

The curriculum spans four weeks and 20 exercises. It starts
with the basics (sessions, windows, panes) and finishes with
automated workspace scripts and a timed SRE drill. After four
weeks it repeats, so skills stay sharp through repetition.

## Learning structure

Each exercise follows the same format:

- **Goal** — one sentence: what you will be able to do
  without thinking by the end of the session.
- **Task** — the exact commands and shortcuts to practise,
  with explanations.
- **Completion goal** — a specific, observable criterion that
  tells you when you are done. No vague "try this" steps.

Exercises are designed to take 10–15 minutes. They are not
tutorials to read — they are drills to repeat until the
muscle memory is there.

### Week 1 — Foundations

Build confidence with the three core tmux concepts.
By Friday you can open a named session, navigate windows and
panes, and recover a running process after closing the
terminal.

| Day | Topic               | What you practise                         |
|-----|---------------------|-------------------------------------------|
| 01  | Sessions            | create → detach → list → attach           |
| 02  | Windows             | create, rename, and navigate windows      |
| 03  | Panes               | split, move between, and zoom panes       |
| 04  | Debugging workspace | run real work inside a named session      |
| 05  | Recovery drill      | close the terminal, reattach, verify      |

### Week 2 — Navigation and Layout

Move past manual arrangement and one-session workflows.
By Friday you have your first `~/.tmux.conf` and can drive
multiple sessions without touching the mouse.

| Day | Topic                  | What you practise                       |
|-----|------------------------|-----------------------------------------|
| 06  | Pane layouts           | cycle presets with `Ctrl-b Space`       |
| 07  | Copy mode I: scrollback| navigate and search history             |
| 08  | Multiple sessions      | switch sessions with `Ctrl-b s`         |
| 09  | Pane synchronisation   | send keystrokes to all panes at once    |
| 10  | tmux.conf basics       | history limit, mouse, live reload       |

### Week 3 — Configuration and Productivity

Own your environment. By Friday you can script a full
workspace layout, address any pane by name, copy text
without the mouse, and capture pane output to a file.

| Day | Topic                    | What you practise                     |
|-----|--------------------------|---------------------------------------|
| 11  | Status bar               | session name, hostname, clock         |
| 12  | Scripted layouts         | build a workspace with `send-keys`    |
| 13  | Target syntax            | `session:window.pane` addressing      |
| 14  | Copy mode II: yank/paste | vi-mode selection, yank, paste        |
| 15  | Capture pane output      | `capture-pane`, `pipe-pane` to file   |

### Week 4 — Real Workflows

Apply everything to the tools you use daily. By Friday
you can build a complete SRE workspace from scratch,
from memory, in under five minutes.

| Day | Topic                       | What you practise                   |
|-----|-----------------------------|-------------------------------------|
| 16  | Multi-repo workspace script | automate a daily layout             |
| 17  | AWS / Terraform workspace   | cloud debugging session             |
| 18  | Manual session snapshot     | save and restore a session          |
| 19  | Live config reload          | iterate on config without restarting|
| 20  | Final drill: SRE workspace  | full build from memory, timed       |

### Progression at a glance

```text
Week 1   You know what tmux is and can stay inside it.
Week 2   You can navigate fluently and configure the basics.
Week 3   You script your environment instead of clicking.
Week 4   tmux is your primary working surface.
```

## Repository layout

```text
tmux-trainer/
├── exercises/
│   ├── day-01.md
│   ├── day-02.md
│   │   …
│   └── day-20.md
├── scripts/
│   ├── tmux-trainer       main script
│   └── install-launchd    macOS launchd installer
├── launchd/
│   └── com.local.tmux-trainer.plist.template
└── .github/workflows/
    └── weekday-reminder.yml
```

## Setup

### 1. Clone

```bash
git clone git@github.com:<YOUR_GITHUB_USER>/tmux-trainer.git
cd tmux-trainer
```

### 2. Make scripts executable

```bash
chmod +x scripts/tmux-trainer scripts/install-launchd
```

### 3. Run manually

```bash
./scripts/tmux-trainer          # today's exercise
./scripts/tmux-trainer 7        # a specific exercise
```

### 4. Install the daily macOS reminder

```bash
./scripts/install-launchd
```

This installs a launchd agent that runs the trainer at 09:00
Monday–Friday and writes logs to:

```text
~/Library/Logs/tmux-trainer.log
~/Library/Logs/tmux-trainer-error.log
```

### 5. Test the scheduled job

```bash
launchctl kickstart -k gui/$(id -u)/com.local.tmux-trainer
```

### 6. Uninstall

```bash
launchctl bootout gui/$(id -u) \
  ~/Library/LaunchAgents/com.local.tmux-trainer.plist
rm ~/Library/LaunchAgents/com.local.tmux-trainer.plist
```

## How the exercise is selected

The script is stateless. It computes today's exercise from
the ISO week number and the day of the week:

```text
week_in_cycle = (ISO_week - 1) % 4   → 0, 1, 2, or 3
exercise      = week_in_cycle × 5 + weekday   → 1 – 20
```

The result is consistent between the local launchd job and
the GitHub Actions workflow — both will always show the same
exercise on the same calendar day.

Weekends fall back to day 1 (Monday of the current cycle)
so a manual run on a Saturday still returns something useful.

## GitHub Actions reminder

`.github/workflows/weekday-reminder.yml` creates a GitHub
issue assigned to the repository owner at 09:00 Berlin time
each weekday, using the same exercise formula.

The workflow fires during 07:00–09:00 UTC and checks the
Berlin clock inside the job to handle DST correctly.

Delete the workflow file if you do not want GitHub issues.

## Suggested next steps

- Track completed exercises in a local state file.
- Add a `tmux-trainer check` command that inspects live
  sessions, windows, and panes to verify completion.
- Add streaks and progress summaries.
- Extend week 4 with team-specific tooling drills.
