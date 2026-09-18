# Scripts

All scripts live in `scripts/` and are executable (`chmod +x`).

## tmux-trainer

**Path:** `scripts/tmux-trainer`

The main runner. Selects today's exercise, shows a macOS notification,
and prints the exercise to stdout.

### Usage

```bash
./scripts/tmux-trainer          # today's exercise (auto-selected)
./scripts/tmux-trainer 7        # a specific exercise by number
```

### How the exercise is selected

The script counts `exercises/day-*.md` files at runtime, so adding
or removing exercise files changes the cycle length automatically
without touching the script.

The day number is derived from the ISO week and weekday:

```text
total = number of day-*.md files in exercises/
day   = ((ISO_week - 1) × 5 + weekday - 1) % total + 1
```

`weekday` is 1 (Monday) through 5 (Friday). Weekends fall back to
Monday (weekday = 1).

The formula cycles through all exercises in order and wraps back to
day 1 after the last one. It is stateless — running the script twice
on the same day always returns the same exercise.

The GitHub Actions workflow uses the same formula, so the issue
created each morning matches what the local script would show.

### macOS notification

The script fires a macOS notification via `osascript` using:

- **Title:** `tmux trainer`
- **Subtitle:** the exercise headline (first `#` line in the file)
- **Body:** the `Goal:` line from the exercise

If `osascript` is not available (non-macOS) the notification is
skipped silently.

### iTerm2 integration (optional)

Set `TMUX_TRAINER_OPEN_ITERM=1` in your shell environment to have the
script open a new iTerm2 window and display the exercise there.

```bash
export TMUX_TRAINER_OPEN_ITERM=1
./scripts/tmux-trainer
```

This is off by default. It has no effect if iTerm2 is not installed
or if `osascript` is unavailable.

## install-launchd

**Path:** `scripts/install-launchd`

Installs a macOS launchd agent that runs `tmux-trainer` at 09:00
Monday–Friday.

### Installation

```bash
./scripts/install-launchd
```

### What it does

1. Reads `launchd/com.local.tmux-trainer.plist.template`
2. Substitutes `__TRAINER_SCRIPT__` and `__HOME__` with real paths
3. Writes the result to
   `~/Library/LaunchAgents/com.local.tmux-trainer.plist`
4. Unloads any previous version (`launchctl bootout`, silent on
   first install)
5. Loads the new version (`launchctl bootstrap`)

### Test without waiting for 09:00

```bash
launchctl kickstart -k gui/$(id -u)/com.local.tmux-trainer
```

### Logs

```bash
tail -f ~/Library/Logs/tmux-trainer.log
tail -f ~/Library/Logs/tmux-trainer-error.log
```

### Uninstall

```bash
launchctl bootout gui/$(id -u) \
  ~/Library/LaunchAgents/com.local.tmux-trainer.plist
rm ~/Library/LaunchAgents/com.local.tmux-trainer.plist
```
