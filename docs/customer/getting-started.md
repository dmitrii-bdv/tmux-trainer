# Getting started

This guide takes you from nothing installed to your first completed
exercise. Plan about 15 minutes for setup, then 10–15 minutes a day.

## What tmux-trainer does

tmux-trainer gives you one short tmux exercise per working day. Each
exercise has a goal, a few tasks to practise in a real tmux session,
and an automatic check that verifies you did them. Over six weeks you
cover sessions, windows, panes, layouts, copy mode, configuration,
status bars, plugins, and more. After week six the cycle starts again.

## 1. Check what you need

| Requirement | Why | How to check |
| --- | --- | --- |
| macOS or Linux | The tool is a shell script | `uname -s` |
| tmux | Exercises run in tmux | `tmux -V` |
| bash or zsh | Runs the script | `echo $SHELL` |
| fzf (optional) | Interactive pickers | `fzf --version` |
| `~/.local/bin` on `PATH` | Where the command is installed | `echo $PATH` |

Install tmux if it is missing:

```bash
# macOS (Homebrew)
brew install tmux

# Debian / Ubuntu
sudo apt-get install -y tmux
```

If `~/.local/bin` is not on your `PATH`, add this line to `~/.zshrc`
or `~/.bashrc`, then open a new terminal:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## 2. Install

From the repository folder:

```bash
make install
tmux-trainer --version
```

You should see `tmux-trainer 1.1.0`. `make install` also installs the
manual page, so `man tmux-trainer` works.

If the version command is not found, check the `PATH` step above.

## 3. Start a tmux session

Exercises assume you work inside tmux. Start one now:

```bash
tmux new -s training
```

Keep this terminal open. Open a second terminal window for the trainer
commands, or run them from inside tmux in a new window.

## 4. Open your first exercise

```bash
tmux-trainer
```

The command prints today's exercise. It also writes a copy you can
annotate to `/tmp/tmux-trainer-day-NN.md`, so your notes never change
the original.

Read the **Goal** first, then work through the **Task** section in
your tmux session.

## 5. Practise the task

Each exercise gives exact commands and shortcuts. Type them, repeat
them, and make the shortcuts automatic. Aim for 10–15 minutes.

Useful shortcuts while you practise:

| Shortcut | Action |
| --- | --- |
| `Ctrl-b ?` | List all tmux key bindings |
| `Ctrl-b d` | Detach from the session (it keeps running) |
| `tmux attach -t training` | Reattach later |

## 6. Verify your work

When the task is done, run the check:

```bash
tmux-trainer check
```

Each line is one assertion, for example that a session exists or a
window is named correctly. Green ticks mean the state matches. A red
cross tells you what is different. Fix it and run the check again.

If the check reports `No check defined`, the exercise has no automatic
check. Compare your work with the completion goal in the exercise.

## 7. Mark the exercise complete

```bash
tmux-trainer done
```

This records the day in your progress log, updates your streak, and
shows your weekly progress. Your first completion unlocks a badge.

Finished the exercise but want to come back to it later? Skip it
instead:

```bash
tmux-trainer skip
```

Skipped exercises return in a spaced-repetition queue. The next time
you open the trainer, due reviews come before the new exercise.

## 8. Build the habit

Run the trainer once a working day. Two options:

- **Manual:** type `tmux-trainer` when you start work.
- **Automatic (macOS):** install the daily 09:00 reminder:

  ```bash
  make install-launchd
  ```

  On weekdays at 09:00 it sends a macOS notification with the day's goal.
  The exercise itself appears when you run `tmux-trainer`.

Good routine: open the trainer, do the exercise, run `check`, run
`done`, then close the tmux session.

## 9. Use the everyday commands

| Command | Use it when |
| --- | --- |
| `tmux-trainer` | You want today's exercise (or a due review) |
| `tmux-trainer 12` | You want exercise 12 |
| `tmux-trainer menu` | You want to pick any exercise with fzf |
| `tmux-trainer --tag config` | You want exercises on one topic |
| `tmux-trainer cheat` | You forgot a shortcut from earlier weeks |
| `tmux-trainer review` | You want a random drill from completed work |
| `tmux-trainer help` | You want the full command list |

Short aliases exist for most commands: `m` (menu), `d` (done),
`s` (skip), `c` (check), `r` (review), `h` (help).

## 10. Optional: shell completions

Tab completion shows subcommands, exercise numbers, and tags:

```bash
make install-completions
```

Then open a new shell and type `tmux-trainer <TAB>`.

## 11. Optional: review from any tmux window

Add this line to `~/.tmux.conf` to start a random drill with
`Ctrl-b r`:

```text
bind-key r run-shell "tmux-trainer review"
```

Reload tmux with `tmux source-file ~/.tmux.conf`.

## 12. Optional: notifications in chat

tmux-trainer can post the day's exercise to Telegram, Slack, or
Discord. Create the file `~/.config/tmux-trainer/conf` and add one line
with your webhook address:

```bash
WEBHOOK_URL="https://your-webhook-address"
```

Every run then posts the exercise title and goal. See
[features](features.md#user-config) for all settings.

## Troubleshooting

| Symptom | Likely cause and fix |
| --- | --- |
| `tmux-trainer: command not found` | `~/.local/bin` is not on `PATH`. See step 1. |
| `check` fails on every line | No tmux session is running. Start `tmux new -s training`. |
| `check` says a session or window is missing | The exercise asks for a specific name. Check the Task section. |
| `done` says "already marked done today" | You already completed today's exercise. Nothing is wrong. |
| Desktop notification does not appear | Notifications are macOS or `notify-send` only. The terminal output is unaffected. |
| Output is hard to read | Set `NO_COLOR=1` for plain text. |

## Where to go next

- [Features](features.md): the full curriculum, every command, and
  the progress, review, and display options.
- [Customer index](index.md): the list of customer documents.
