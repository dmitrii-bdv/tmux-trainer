# tmux-trainer

A small learn-by-doing tmux training repo for macOS + iTerm2.

It gives you one practical tmux exercise per working day, shows a macOS notification,
and can open the exercise in your terminal.

## Design

```text
tmux-trainer/
├── exercises/
│   ├── day-01.md
│   ├── day-02.md
│   ├── day-03.md
│   ├── day-04.md
│   └── day-05.md
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
./scripts/tmux-trainer 3
```

### 4. Install the weekday macOS reminder

```bash
./scripts/install-launchd
```

The default schedule is 09:00, Monday-Friday.

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
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.local.tmux-trainer.plist
rm ~/Library/LaunchAgents/com.local.tmux-trainer.plist
```

## What happens when it runs?

The trainer:

1. chooses an exercise based on the weekday;
2. sends a macOS notification;
3. writes today's exercise path to the terminal;
4. optionally opens iTerm2 with the exercise.

Run:

```bash
./scripts/tmux-trainer
```

to see the exercise directly.

## GitHub Actions reminder

`.github/workflows/weekday-reminder.yml` is included as an optional cloud-side reminder.

It creates a GitHub issue assigned to the repository owner on weekdays.

GitHub Actions cron schedules use UTC, so the included workflow runs hourly during a small
morning window and checks `Europe/Berlin` inside the job. This avoids DST problems.

If you don't want GitHub issue reminders, simply delete the workflow.

## Suggested next steps

Once the basic trainer works, useful additions are:

- track completed exercises;
- randomly choose drills from a larger exercise pool;
- inspect live tmux sessions/windows/panes;
- verify that an exercise was completed;
- add streaks and progress;
- add Kubernetes/Terraform/AWS-specific tmux challenges;
- add an interactive `tmux-trainer check` command.
