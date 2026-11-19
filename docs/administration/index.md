# Administration index

Internal documentation for maintainers of tmux-trainer. Customer-facing
material lives in [docs/customer](../customer/index.md).

## What this project is

tmux-trainer is a dependency-free shell tool that delivers one tmux
exercise per working day. It tracks completions, streaks, and
spaced-repetition reviews, and verifies the tmux state with checks
written into each exercise. A daily reminder runs through macOS
launchd or a GitHub Actions workflow.

Current release: **v1.4.0**. See [CHANGELOG](../../CHANGELOG.md).

## Components

| Component | Location | Purpose |
| --- | --- | --- |
| Entry point | `scripts/tmux-trainer` | Loads the library and dispatches commands |
| Library | `lib/*.sh` | Config, dates, catalog, state, SRS, checks, notifications, help |
| Subcommands | `lib/commands/*.sh` | One file per user command |
| Exercises | `exercises/day-NN.md` | 41 Markdown lessons with a `## Check` block |
| Completions | `completions/` | zsh and bash tab completion, read from the tool |
| Reminder (macOS) | `scripts/install-launchd`, `launchd/` | Daily 09:00 launchd agent |
| Reminder (CI) | `.github/workflows/weekday-reminder.yml` | Daily GitHub issue, plus Telegram, Slack, Discord, or e-mail when configured |
| CI | `.github/workflows/ci.yml` | ShellCheck, exercise lint, Bats tests |
| Tests | `tests/` | Bats unit and end-to-end tests |

## Why it is built this way

- **Bash, no runtime dependencies.** Installs anywhere with a shell and
  tmux; no package manager required for the CLI.
- **Exercises are content, not code.** Adding an exercise file extends
  the cycle automatically. Checks are declarative lines, not scripts.
- **One source for help, man page, and completions.** The command table
  in `lib/help.sh` feeds all three; completions read the live exercise
  list.
- **Plain-text state.** The log, SRS queue, and current-exercise marker
  live under `~/.local/share/tmux-trainer/`. Easy to inspect and back up.
- **Testable seams.** Environment variables override the date, temp
  directory, exercise directory, and notifications. See
  [architecture](architecture.md).

Decisions and their rationale are recorded in
[architecture](architecture.md#decisions).

## How to

| Task | Document |
| --- | --- |
| Understand the code layout and extension points | [architecture](architecture.md) |
| Run tests, lint, and add or edit exercises | [development](development.md) |
| Cut a release and write its notes | [development](development.md#release-process) |
| Install and debug the macOS reminder | [scripts](scripts.md#install-launchd) |
| Configure the GitHub Actions reminder and secrets | [github-workflow](github-workflow.md) |
| Look up a script's behaviour and options | [scripts](scripts.md) |

## Quick commands

```bash
make install          # symlink the CLI and install the man page
make test             # ShellCheck, exercise lint, and Bats tests
make install-launchd  # macOS daily reminder
tmux-trainer lint     # validate exercise files only
```

## Ownership

Maintainer: Dmitrii Bedov (<dmitrii@bedov.ch>). Licence: PolyForm
Noncommercial 1.0.0 (see [LICENSE](../../LICENSE)).
