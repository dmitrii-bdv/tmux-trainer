# Architecture

This page describes how tmux-trainer is structured, why, and where to
extend it. Read [the admin index](index.md) first for the overview.

## Layers

```text
exercises/day-NN.md        content: lessons and declarative checks
        │
lib/catalog.sh             discovery and parsing of exercises
lib/assert.sh              check engine (tmux, files, options)
lib/srs.sh                 spaced-repetition queue
lib/state.sh               log, streaks, weekly bar, badges
lib/notify.sh              desktop notifications, webhook payloads
lib/help.sh                command table → help and man page
lib/config.sh, dates.sh    configuration and portable date helpers
        │
lib/commands/*.sh          one function per subcommand (cmd_*)
        │
scripts/tmux-trainer       entry point: load libs, dispatch
```

Each layer only calls the layers below it. Commands never parse files
directly; they go through `catalog.sh` and `state.sh`.

## Module map

| Module | Main functions | Notes |
| --- | --- | --- |
| `config.sh` | `TMUX_TRAINER_VERSION`, paths, icons | Reads `~/.config/tmux-trainer/conf` |
| `dates.sh` | `_today`, `_date_fmt`, `_date_add` | Works with GNU and BSD date |
| `catalog.sh` | `_ex_file`, `_ex_title`, `_ex_check_lines`, `_current_day` | Exercise numbers are contiguous |
| `state.sh` | `_log_append`, `_streak`, `_week_bar`, `_check_badges` | Plain-text log |
| `srs.sh` | `_srs_update`, `_srs_due_list` | Intervals 1, 3, 7, 21 days |
| `assert.sh` | `_split_args`, `_validate_assertion_line`, `_assert` | Quoted arguments supported |
| `notify.sh` | `notify_desktop`, `send_webhook`, escapers | Escapes JSON and AppleScript |
| `help.sh` | `_command_rows`, `cmd_help`, `_generate_man` | Single source for help |
| `commands/*.sh` | `cmd_show`, `cmd_done`, `cmd_check`, … | Return codes map to exit codes |
| `commands/exam.sh` | `cmd_exam`, `_exam_pick`, `_exam_finish`, `_exam_timer` | State in `LOG_DIR/exam`; countdown runs in a tmux split pane |

## State on disk

| File | Format | Written by |
| --- | --- | --- |
| `~/.local/share/tmux-trainer/log` | `DATE PAD completed\|skipped` or `DATE badge NAME` | `done`, `skip`, badges |
| `~/.local/share/tmux-trainer/srs` | `PAD<TAB>LAST_DATE<TAB>REPS` | `done`, `skip` |
| `~/.local/share/tmux-trainer/current` | `PAD` | `show` |
| `~/.local/share/tmux-trainer/time_start` | epoch seconds | `show` on day 20 |
| `/tmp/tmux-trainer-day-NN.md` | Markdown copy | `show` |

These formats are the contract between versions. Changing them needs a
migration note in the changelog.

## Checks as data

Each exercise lists assertions as lines inside a ```` ```text ```` block
under `## Check`:

```text
session_exists  training
window_named    training shell
option_set      mouse on
file_contains   ~/.tmux.conf "run '~/.tmux/plugins/tpm/tpm'"
```

The core only knows the assertion types and their argument counts
(`_assert_arity`). Adding a new type means one `case` branch in
`assert.sh`, its arity in `_assert_arity`, and a test. `tmux-trainer lint`
rejects unknown types and wrong argument counts in every exercise.

This vocabulary is also the planned contract for a future website that
emulates tmux: the same assertions would be evaluated against simulated
state instead of a real server.

## Testing seams

| Variable | Purpose |
| --- | --- |
| `TMUX_TRAINER_TODAY` | Fixes "today" (YYYY-MM-DD) |
| `TMUX_TRAINER_EXERCISE_DIR` | Uses another exercise directory |
| `TMUX_TRAINER_TMP_DIR` | Changes where working copies go |
| `TMUX_TRAINER_NO_NOTIFY` | Suppresses desktop notifications |
| `NO_COLOR` | Plain-text output (also used when the terminal is narrow) |

Tests set these in `tests/helpers.bash` and run with an isolated `HOME`.

## Decisions

Each decision lists what was chosen and what was rejected.

1. **Keep Bash for the CLI (v1.1.0).** Chosen: zero runtime dependencies
   and an unchanged install path. Rejected for now: a rewrite before the
   website exists. The core can be ported later once it is covered by
   tests.
2. **Modularise into `lib/` and `lib/commands/`.** Chosen: small files
   with one responsibility each. Rejected: keeping the 929-line script,
   which made tests and reuse impossible.
3. **Generate help and man from one table.** Chosen: `lib/help.sh`.
   Rejected: separate hand-written help and troff text that drifted (the
   man page said 24 exercises when there are 41).
4. **Derive completions from the tool.** Chosen: `--list-days` and
   `--list-tags`. Rejected: hard-coded lists that needed manual updates.
5. **Quoted arguments in checks.** Chosen: a small tokenizer, no `eval`.
   Rejected: word splitting, which broke multi-word arguments such as
   `/tmp/my file.txt`.
6. **Exact tag matching.** `--tag copy-mode` no longer matches `mode`.
7. **Bats for tests, ShellCheck for linting, CI on every push and PR.**
8. **Website later, TypeScript core.** Deferred until the website work
   starts. The website may use npm; the CLI stays dependency-free until
   then.

## Extension points

- **New subcommand:** add `lib/commands/NAME.sh` with `cmd_NAME`, add a
  row to `_command_rows` in `lib/help.sh`, and add a `case` branch in
  `scripts/tmux-trainer`.
- **New assertion type:** see [Checks as data](#checks-as-data).
- **New notification channel:** add a branch in `send_webhook` and a
  test that captures the payload.
- **New exercise:** see [development](development.md#add-an-exercise).
