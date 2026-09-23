# Scripts

All scripts live in `scripts/` and are executable (`chmod +x`).

## tmux-trainer

**Path:** `scripts/tmux-trainer`

The main runner. Selects today's exercise, shows a macOS notification,
and prints the exercise to stdout.

### Usage

```bash
./scripts/tmux-trainer              # today's exercise (SRS queue first)
./scripts/tmux-trainer 7            # a specific exercise by number
./scripts/tmux-trainer menu         # fzf picker to jump to any exercise
./scripts/tmux-trainer done         # mark completed, advance SRS interval
./scripts/tmux-trainer skip         # queue for review tomorrow (SM-2)
./scripts/tmux-trainer check        # verify today's tmux state
./scripts/tmux-trainer check 12     # verify a specific day's state
./scripts/tmux-trainer cheat        # shortcuts from exercises 1 to today
./scripts/tmux-trainer cheat --all  # shortcuts from all exercises
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

### Progress tracking

Completions are recorded in an append-only log at:

```text
~/.local/share/tmux-trainer/log
```

Each line is one entry:

```text
2026-09-18 04 completed
2026-09-17 03 completed
2026-09-16 02 skipped
```

The file is human-readable and directly editable.

**Streak counter** — every run shows consecutive completed weekdays:

```text
🔥 5-day streak  ·  [████░] 4/5 this week
```

**Week progress bar** — five blocks, one per weekday. Filled blocks
are days where `done` was called. On weekends the bar shows the
completed week.

**`tmux-trainer done`** — appends a `completed` entry for today and
prints the updated streak and bar. Intentionally manual so you decide
when the exercise is actually finished:

```text
✓ Day 04 marked as completed
🔥 5-day streak  ·  [████░] 4/5 this week
```

Running `done` twice on the same day is a no-op.

**Milestone badges** — earned once, printed immediately after `done`,
and stored in the log (`badge` lines):

| Badge | Condition |
| --- | --- |
| First completion | First ever `done` call |
| First full week | All 5 weekdays completed in a single week |
| First full cycle | Every exercise completed at least once |

Badge log lines look like:

```text
2026-09-18 badge first-done
2026-09-25 badge first-week
```

### Spaced repetition (SM-2)

`tmux-trainer skip` flags the current exercise for spaced review.
The script re-surfaces it on an SM-2 schedule:

| Consecutive passes | Next review |
| --- | --- |
| 0 (just skipped) | tomorrow |
| 1 | 3 days later |
| 2 | 7 days later |
| 3+ | 21 days later |

Calling `skip` again after any number of passes resets the
interval back to 1 day.

When reviews are due, `tmux-trainer` (no args) shows the
oldest-due exercise before the calendar exercise. The header
shows how many reviews are pending and the current interval:

```text
📚 SRS review (2 due)  ·  interval 3d → 7d on pass
🔥 4-day streak  ·  [████░] 4/5 this week
```

After calling `done` on a review, the interval advances. After
calling `skip`, it resets to 1 day.

SRS state is stored in a tab-separated file separate from the
main log:

```text
~/.local/share/tmux-trainer/srs
```

Format: `EXERCISE_PAD<TAB>LAST_DATE<TAB>REPS`

```text
03 2026-09-16 0
12 2026-09-14 2
```

Only exercises you explicitly skip enter the queue. Completing
a calendar exercise via `done` does not add it to SRS — the
queue stays focused on exercises you actually struggled with.

### Live state verification

`tmux-trainer check` reads the `## Check` section of the current
exercise and verifies your actual tmux state against it:

```text
$ tmux-trainer check
Checking day 04 — Multi-Session Workflow

  ✓ session debug exists
  ✓ window kube exists in debug
  ✓ window aws exists in debug
  ✗ window logs exists in debug   ← not found

1 assertion failed
```

Pass a day number to check a specific exercise:

```bash
tmux-trainer check 12
```

Each exercise file has a `## Check` section with a fenced
` ```text ` block listing assertions, one per line:

```text
session_exists  debug
window_named    debug kube
window_named    debug aws
window_named    debug logs
```

**Assertion types:**

| Type | Arguments | Checks |
| --- | --- | --- |
| `session_exists` | `name` | session is running |
| `window_count` | `session count` | exact window count |
| `window_named` | `session name` | window with that name exists |
| `pane_count` | `session:window count` | exact pane count in window |
| `pane_running` | `session:window cmd` | pane running a process |
| `option_set` | `option value` | global tmux option value |
| `file_exists` | `path` | file or directory exists |

Exercises 07 and 13 have no `## Check` section — they focus on
concepts with no structural state to verify.

### Cheat sheet

`tmux-trainer cheat` prints all `Ctrl-b` shortcuts introduced in
exercises 1 through today's exercise, grouped by day:

```text
=== tmux cheat sheet (days 1–8) ===

Day 2 — Windows
  Ctrl-b c       new window
  Ctrl-b ,       rename window
  ...

Day 3 — Panes
  Ctrl-b %       vertical split
  ...
```

Shortcuts are extracted from the ` ```text ` blocks in each exercise
file, so the cheat sheet always reflects the actual exercise content.

Pass `--all` to include every exercise regardless of today's day:

```bash
./scripts/tmux-trainer cheat --all
```

### Working copy (vimtutor pattern)

Each run copies the exercise to a temp file before displaying it:

```text
/tmp/tmux-trainer-day-NN.md
```

You can annotate it freely — cross off steps, add notes — without
touching the repo. The copy is refreshed only when the source
exercise file is newer, so your annotations survive re-runs of the
same day.

The path is printed at the end of every run:

```text
  → annotate freely: /tmp/tmux-trainer-day-04.md
  → run `tmux-trainer done` when you finish
```

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
