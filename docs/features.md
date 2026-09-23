# Features

All currently implemented features of tmux-trainer.

---

## Curriculum

Five weeks, 24 exercises. After week 5 the cycle repeats, so
skills stay sharp through repetition.

### Week 1 — Foundations

| Day | Topic               | What you practise                       |
|-----|---------------------|-----------------------------------------|
| 01  | Sessions            | create → detach → list → attach         |
| 02  | Windows             | create, rename, and navigate windows    |
| 03  | Panes               | split, move between, and zoom panes     |
| 04  | Debugging workspace | run real work inside a named session    |
| 05  | Recovery drill      | close the terminal, reattach, verify    |

### Week 2 — Navigation and Layout

| Day | Topic                   | What you practise                          |
|-----|-------------------------|--------------------------------------------|
| 06  | Pane layouts            | cycle presets with `Ctrl-b Space`          |
| 07  | Copy mode I: scrollback | navigate and search history                |
| 08  | Multiple sessions       | switch sessions with `Ctrl-b s`            |
| 09  | Pane synchronisation    | send keystrokes to all panes at once       |
| 10  | tmux.conf basics        | history limit, mouse, pane titles, reload  |

### Week 3 — Configuration and Productivity

| Day | Topic                    | What you practise                   |
|-----|--------------------------|-------------------------------------|
| 11  | Status bar               | session name, hostname, clock       |
| 12  | Scripted layouts         | build a workspace with `send-keys`  |
| 13  | Target syntax            | `session:window.pane` addressing    |
| 14  | Copy mode II: yank/paste | vi-mode selection, yank, paste      |
| 15  | Capture pane output      | `capture-pane`, `pipe-pane` to file |

### Week 4 — Real Workflows

| Day | Topic                       | What you practise                 |
|-----|-----------------------------|-----------------------------------|
| 16  | Multi-repo workspace script | automate a daily layout           |
| 17  | AWS / Terraform workspace   | cloud debugging session           |
| 18  | Manual session snapshot     | save and restore a session        |
| 19  | Live config reload          | iterate on config without restart |
| 20  | Final drill: SRE workspace  | full build from memory, timed     |

### Week 5 — Advanced Layouts

| Day | Topic                    | What you practise                        |
|-----|--------------------------|------------------------------------------|
| 21  | Sized splits             | create panes with exact percentages      |
| 22  | Side panel               | persistent side pane alongside main work |
| 23  | Asymmetric layout script | script a custom non-standard layout      |
| 24  | Dev workspace setup      | full dev workspace script from scratch   |

### Progression at a glance

```text
Week 1   You know what tmux is and can stay inside it.
Week 2   You can navigate fluently and configure the basics.
Week 3   You script your environment instead of clicking.
Week 4   tmux is your primary working surface.
Week 5   You build precise, scripted layouts from memory.
```

---

## Exercise format

Each exercise file follows the same structure:

- **Goal** — one sentence stating what you will be able to do
  without thinking by the end of the session.
- **Task** — exact commands and shortcuts to practise, with
  explanations.
- **Completion goal** — a specific, observable criterion that
  tells you when you are done.
- **Check** — machine-readable assertions for `tmux-trainer check`.
- **Workflow** — the four-step loop: read → practise → check → done.

Exercises are drills to repeat, not tutorials to read.
Target time per session: 10–15 minutes.

---

## Exercise selection

The script is stateless. It counts `exercises/day-*.md` files at
runtime and computes today's exercise from the ISO week and weekday:

```text
total    = number of day-*.md files
exercise = ((ISO_week - 1) × 5 + weekday - 1) % total + 1
```

Weekdays are 1 (Mon) through 5 (Fri). Weekends fall back to 1.

Adding a new exercise file automatically extends the cycle — no
code changes needed. The GitHub Actions workflow uses the same
formula, so the daily issue always matches the local script.

---

## Subcommands

```bash
tmux-trainer               # today's exercise (SRS queue first)
tmux-trainer 7             # a specific exercise by number
tmux-trainer menu    | m   # fzf picker to jump to any exercise
tmux-trainer done    | d   # mark completed, advance SRS interval
tmux-trainer skip    | s   # queue for review tomorrow (SM-2)
tmux-trainer check   | c   # verify today's tmux state
tmux-trainer check 12      # verify a specific day's state
tmux-trainer cheat         # shortcuts from exercises 1 to today
tmux-trainer cheat --all   # shortcuts from all 24 exercises
tmux-trainer review  | r   # random completed exercise as a drill
tmux-trainer help    | h   # show the built-in man page
tmux-trainer --tag NAME    # filter exercises by tag
```

Every subcommand has a single-character alias (`m`, `d`, `s`, `c`,
`r`, `h`).

### help

Prints a man-style page covering synopsis, all subcommands, file
paths, the tmux keybinding tip, and usage examples.

### review

Picks a random exercise from your completion log and opens it as
an unscheduled drill. Complements the SRS queue by letting you
interleave past material at will.

```text
🎲 Random drill: Day 07
```

### menu

Presents all 24 exercises in an interactive `fzf` picker. Select
one to open it directly. Falls back to shell `select` if `fzf` is
not installed.

### --tag

Filters the exercise list to those matching a tag and opens them
in an fzf picker (or `select` if fzf is absent). If exactly one
exercise matches, it opens directly.

```bash
tmux-trainer --tag copy-mode
tmux-trainer --tag config
tmux-trainer --tag scripting
```

Available tags:

| Tag          | Exercises                          |
|--------------|------------------------------------|
| `sessions`   | 01, 04, 05, 08, 18                 |
| `windows`    | 02, 04                             |
| `panes`      | 03, 06, 09, 15, 21, 22             |
| `layouts`    | 06, 12, 21, 22, 23                 |
| `copy-mode`  | 07, 14                             |
| `navigation` | 07, 08, 13                         |
| `config`     | 10, 11, 19                         |
| `status-bar` | 11                                 |
| `scripting`  | 12, 13, 15, 16, 17, 20, 23, 24     |
| `workflow`   | 04, 16, 17, 20, 24                 |
| `recovery`   | 05, 18                             |
| `sync`       | 09                                 |

Each exercise file declares its own tags on a `tags:` line
directly below the `Goal:` line, so the set is always
authoritative.

### done / skip

Both are intentionally manual — you decide when the exercise is
finished, which forces honest self-assessment.

`done` appends a `completed` entry and prints the updated streak
and week bar. Running `done` twice on the same day is a no-op.

`skip` appends a `skipped` entry and queues the exercise for
spaced-repetition review.

### check

Reads the `## Check` section of the exercise and verifies your
live tmux state. Supported assertion types:

| Type            | Arguments            | What it checks              |
|-----------------|----------------------|-----------------------------|
| `session_exists`| `name`               | session is running          |
| `window_count`  | `session count`      | exact window count          |
| `window_named`  | `session name`       | window with that name       |
| `pane_count`    | `session:window n`   | exact pane count in window  |
| `pane_running`  | `session:window cmd` | pane running a process      |
| `option_set`    | `option value`       | global tmux option value    |
| `file_exists`   | `path`               | file or directory exists    |
| `pane_contains` | `target pattern`     | pattern in pane scrollback  |
| `file_contains` | `path pattern`       | pattern found in file       |

Pass a day number to check a specific exercise:

```bash
tmux-trainer check 12
```

### cheat

Prints all `Ctrl-b` shortcuts introduced up to today's exercise,
grouped by day. Extracted from the ` ```text ` blocks in exercise
files, so the sheet always reflects actual content.

---

## Progress tracking

Completions are recorded in an append-only log:

```text
~/.local/share/tmux-trainer/log
```

Format — one entry per line:

```text
2026-09-18 04 completed
2026-09-17 03 completed
2026-09-16 02 skipped
2026-09-18 badge first-done
```

The file is human-readable and directly editable.

### Streak counter

Every run prints consecutive completed weekdays:

```text
🔥 5-day streak  ·  [████░] 4/5 this week
```

### Week progress bar

Five blocks, one per weekday. Filled blocks are days where `done`
was called. On weekends the bar shows the completed week.

### Milestone badges

Earned once, stored in the log, printed immediately after `done`:

| Badge            | Condition                                    |
|------------------|----------------------------------------------|
| First completion | First ever `done` call                       |
| First full week  | All 5 weekdays completed in a single week    |
| First full cycle | Every exercise completed at least once       |

---

## Timed mode (day 20)

Day 20 — Final drill: SRE workspace — is designed to be completed
from memory in under 5 minutes. The script records a start
timestamp when day 20 is opened, then measures elapsed time when
`tmux-trainer done` is called:

```text
⏱  Completed in 4m 22s  (target: < 5m)
```

Or if you went over:

```text
⏱  Completed in 6m 11s  (target: < 5m — over by 131s)
```

The timestamp is stored in `~/.local/share/tmux-trainer/time_start`
and deleted after `done` reads it. Re-opening day 20 resets the
clock.

---

## Spaced repetition (SM-2)

`tmux-trainer skip` queues the exercise for spaced review using an
SM-2 schedule:

| Consecutive passes | Next review |
|--------------------|-------------|
| 0 (just skipped)   | tomorrow    |
| 1                  | 3 days      |
| 2                  | 7 days      |
| 3+                 | 21 days     |

Skipping again after any number of passes resets the interval to
1 day.

When reviews are due, `tmux-trainer` (no args) shows the
oldest-due exercise before the calendar exercise:

```text
📚 SRS review (2 due)  ·  interval 3d → 7d on pass
```

SRS state is stored separately from the main log:

```text
~/.local/share/tmux-trainer/srs
```

Format: `EXERCISE_PAD<TAB>LAST_DATE<TAB>REPS`

Only exercises explicitly skipped enter the queue. Completing
a calendar exercise via `done` does not add it to SRS.

### Deck-size guardrail

When more than 10 exercises are pending review, a warning is
printed before the exercise to prompt a catch-up session:

```text
⚠  11 reviews due — consider a catch-up session first.
```

---

## Notification

Fires on every run. Platform is detected automatically:

- **macOS** — `osascript` (title, subtitle, body)
- **Linux** — `notify-send` (title + subtitle in one field, body)
- **Other** — skipped silently if neither tool is available

Notification content:

- **Title:** `tmux trainer — <exercise headline>`
- **Body:** `Goal:` text · `Run: tmux-trainer`

---

## Working copy (vimtutor pattern)

Each run copies the exercise to a temp file before displaying it:

```text
/tmp/tmux-trainer-day-NN.md
```

You can annotate it freely without touching the repo. The copy
is refreshed only when the source file is newer, so annotations
survive re-runs of the same day.

---

## Daily reminder (launchd)

`scripts/install-launchd` installs a macOS launchd agent that
fires `tmux-trainer` at 09:00 Monday–Friday.

Logs:

```text
~/Library/Logs/tmux-trainer.log
~/Library/Logs/tmux-trainer-error.log
```

Test the job without waiting for 09:00:

```bash
launchctl kickstart -k gui/$(id -u)/com.local.tmux-trainer
```

---

## Symlink resolution

The script resolves symlinks at runtime, so it always finds its
exercises regardless of how it is invoked — directly, via a
`~/.local/bin` symlink, or from any working directory.

---

## iTerm2 integration (optional)

Set `TMUX_TRAINER_OPEN_ITERM=1` to open a new iTerm2 window
displaying the exercise on each run. Off by default. No effect
if iTerm2 is not installed.

---

## User config

Create `~/.config/tmux-trainer/conf` to override defaults. The
file is sourced as bash, so use standard variable assignments:

```bash
# Override log location
LOG_DIR="${HOME}/my-logs/tmux-trainer"

# Webhook URL for daily reminders (Slack, Discord, Telegram)
WEBHOOK_URL=""

# Disable emoji and colour output
NO_COLOR=1
```

Available overrides:

| Variable      | Default                                    | Effect                      |
|---------------|--------------------------------------------|-----------------------------|
| `LOG_DIR`     | `~/.local/share/tmux-trainer`              | Move log and SRS files      |
| `WEBHOOK_URL` | `""`                                       | POST daily reminder payload |
| `NO_COLOR`    | unset                                      | Force plain-text output     |

---

## Plain-text output (NO_COLOR)

Set `NO_COLOR` in your environment or config file to replace all
emoji with plain ASCII indicators. Also activates automatically
when the terminal is narrower than 60 columns.

```bash
export NO_COLOR=1
tmux-trainer
```

Wide output:

```text
🔥 5-day streak  ·  [████░] 4/5 this week
✓ Day 04 marked as completed
```

Narrow / NO_COLOR output:

```text
> 5-day streak
+ Day 04 marked as completed
```

---

## Shell completions

Completion files live in `completions/`. Install once:

### zsh

```bash
mkdir -p ~/.zsh/completions
cp completions/tmux-trainer.zsh ~/.zsh/completions/_tmux_trainer
# Ensure ~/.zsh/completions is in your fpath, e.g. in ~/.zshrc:
#   fpath=(~/.zsh/completions $fpath)
#   autoload -Uz compinit && compinit
```

### bash

```bash
cp completions/tmux-trainer.bash /usr/local/etc/bash_completion.d/tmux-trainer
source /usr/local/etc/bash_completion.d/tmux-trainer
```

Or use `make install-completions` to copy both at once.

Completions cover: all subcommands, day numbers 1–24, `--tag`
values, `--all` after `cheat`, and day numbers after `check`/`skip`.

---

## Installation (Makefile)

A `Makefile` provides one-command installation:

```bash
make install             # symlink + man page
make install-completions # bash and zsh completions
make install-launchd     # macOS daily reminder
make uninstall           # remove all installed files
```

Override install paths:

```bash
make install BIN_DIR=~/bin
make install-completions ZSH_COMP=~/.config/zsh/completions
```
