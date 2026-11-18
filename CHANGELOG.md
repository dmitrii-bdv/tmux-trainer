# Changelog

All notable changes to tmux-trainer are documented here. The format
follows [Keep a Changelog](https://keepachangelog.com/), and versions
follow [Semantic Versioning](https://semver.org/).

## v1.2.0 - 2026-11-18

### Added

- Exam mode: `tmux-trainer exam [MINUTES]` runs a 20-minute timed drill
  over five completed exercises (least-used first). A countdown pane
  scores the checks automatically when time runs out. `exam finish`
  scores early.

## v1.1.0

Architecture release. Command behaviour is unchanged except for the
fixes listed below.

### Changed

- Split the single-file script into `lib/` modules and one file per
  subcommand under `lib/commands/`. The entry point is now thin.
- Help text and the man page are generated from one command table.
- Shell completions read exercise numbers and tags from the tool, so
  they no longer need manual updates.
- Documentation is organised into `docs/customer/` and
  `docs/administration/`.

### Added

- `tmux-trainer lint` validates every exercise file.
- `tmux-trainer --version`, `--list-days`, and `--list-tags`.
- Bats test suite (`make test`) and a CI workflow running ShellCheck,
  exercise lint, and tests on every push and pull request.
- A licence section in the README, the script header, and the man page.

### Fixed

- Check arguments with spaces, such as `/tmp/my file.txt`, are now
  parsed correctly. Three exercises had unquoted multi-word arguments.
- `file_contains` and `pane_contains` match literal text, not regular
  expressions. Patterns such as `status-format[1]` now match as written.
- Week numbers 08 and 09 no longer break the day calculation.
- Day numbers with a leading zero, such as `08`, are accepted.
- Webhook and desktop notification text is escaped, so titles with quotes
  no longer produce invalid JSON or AppleScript.
- `--tag` matches whole tags only, so `mode` no longer matches
  `copy-mode`.
- The man page and help text now report 41 exercises, not 24.

## v1.0.0

First stable release. Includes the 41-day curriculum, daily reminders
(launchd and GitHub Actions), spaced repetition, streaks and badges,
the `check` command, webhook notifications, and the PolyForm
Noncommercial licence.
