# tmux-trainer

A learn-by-doing tmux training repo for macOS + iTerm2.

One practical exercise per working day, delivered as a macOS
notification. The curriculum spans four weeks (20 exercises)
and repeats on a four-week cycle keyed to the ISO week number.

## Curriculum

### Week 1 — Foundations

| Day | Topic                  |
|-----|------------------------|
| 01  | Sessions               |
| 02  | Windows                |
| 03  | Panes                  |
| 04  | Debugging workspace    |
| 05  | Recovery drill         |

### Week 2 — Navigation & Layout

| Day | Topic                  |
|-----|------------------------|
| 06  | Pane layouts           |
| 07  | Copy mode I: scrollback|
| 08  | Multiple sessions      |
| 09  | Pane synchronization   |
| 10  | tmux.conf basics       |

### Week 3 — Configuration & Productivity

| Day | Topic                    |
|-----|--------------------------|
| 11  | Status bar               |
| 12  | Scripted layouts         |
| 13  | Target syntax            |
| 14  | Copy mode II: yank/paste |
| 15  | Capture pane output      |

### Week 4 — Real Workflows

| Day | Topic                      |
|-----|----------------------------|
| 16  | Multi-repo workspace script|
| 17  | AWS / Terraform workspace  |
| 18  | Manual session snapshot    |
| 19  | Live config reload         |
| 20  | Final drill: SRE workspace |

## Design

```text
tmux-trainer/
├── exercises/
│   ├── day-01.md  …  day-20.md
├── scripts/
│   ├── tmux-trainer
│   └── install-launchd
├── launchd/
│   └── com.local.tmux-trainer.plist.template
└── .github/workflows/
    └── weekday-reminder.yml
```

## Recommended workflow

### 1. Clone the repo

```bash
git clone git@github.com:<YOUR_GITHUB_USER>/tmux-trainer.git
cd tmux-trainer
```

### 2. Make the trainer executable

```bash
chmod +x scripts/tmux-trainer scripts/install-launchd
```

### 3. Try it manually

```bash
./scripts/tmux-trainer
```

Show a specific exercise:

```bash
./scripts/tmux-trainer 7
```

### 4. Install the weekday macOS reminder

```bash
./scripts/install-launchd
```

The default schedule is 09:00, Monday–Friday.

The installer creates:

```text
~/Library/LaunchAgents/com.local.tmux-trainer.plist
```

and loads it with `launchctl`.

### 5. Test the scheduled task

```bash
launchctl kickstart -k gui/$(id -u)/com.local.tmux-trainer
```

### 6. Remove it

```bash
launchctl bootout gui/$(id -u) \
  ~/Library/LaunchAgents/com.local.tmux-trainer.plist
rm ~/Library/LaunchAgents/com.local.tmux-trainer.plist
```

## How the exercise is chosen

The script uses the ISO week number and the day of the week
to pick an exercise in the 4-week cycle:

```text
week_in_cycle = (ISO_week - 1) % 4        # 0-3
exercise      = week_in_cycle * 5 + weekday  # 1-20
```

This is stateless and consistent across both the local
launchd job and the GitHub Actions workflow.

## GitHub Actions reminder

`.github/workflows/weekday-reminder.yml` creates a GitHub
issue assigned to the repo owner each weekday at 09:00
Berlin time, using the same 4-week exercise formula.

If you don't want GitHub issue reminders, delete the
workflow file.

## Suggested next steps

- Track completed exercises with a local state file.
- Add an interactive `tmux-trainer check` command that
  inspects live tmux sessions/windows/panes.
- Add streaks and progress visualization.
