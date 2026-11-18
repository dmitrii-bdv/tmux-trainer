# GitHub Workflow: Weekday Reminder

`weekday-reminder.yml` creates a GitHub issue each weekday at your
chosen Berlin time and sends a Telegram notification.

## How it works

### Schedule

The cron fires every hour from 04:00–11:00 UTC, Monday–Friday.
That window covers Berlin 06:00–12:00 in both winter (CET, UTC+1)
and summer (CEST, UTC+2).

On each run the job reads the current Berlin hour and compares it
against the `REMINDER_HOUR` variable. Only one run per day matches;
the rest exit immediately without doing anything.

### Exercise selection

The exercise number is derived from the date — no state file needed.
The workflow counts `exercises/day-*.md` files at runtime, so adding
new exercise files extends the cycle without any code change.

```text
total    = number of day-*.md files checked out
exercise = ((ISO_week - 1) × 5 + weekday - 1) % total + 1
```

`weekday` is 1 (Mon) through 5 (Fri). The result is identical to
what the local `tmux-trainer` script computes, so the GitHub issue
and the macOS notification always show the same exercise.

### Steps

| Step | What it does |
| --- | --- |
| Decide whether this is the target Berlin hour | Reads `vars.REMINDER_HOUR`; exits early if the hour does not match |
| Checkout | Clones the repo so exercise files are available |
| Create today's training issue | Reads the matching `exercises/day-NN.md`, creates a GitHub issue, captures the URL and title |
| Send Telegram notification | POSTs to the Telegram Bot API with the issue title and URL |

### Skipping on `workflow_dispatch`

Triggering the workflow manually via the GitHub UI (Actions →
Run workflow) bypasses the hour check and runs all steps
immediately. Use this to test the setup.

## Required configuration

### Variable: `REMINDER_HOUR`

Controls which Berlin hour triggers the reminder.

**Where:** Repository → Settings → Secrets and variables →
Variables → New repository variable

| Name | Example value | Notes |
| --- | --- | --- |
| `REMINDER_HOUR` | `09` | Zero-padded 24-hour clock. Range: `06`–`12`. Default if unset: `09`. |

### Secrets: Telegram bot

Both secrets are required for Telegram notifications. If either is
missing the Telegram step is skipped silently (the issue is still
created).

**Where:** Repository → Settings → Secrets and variables →
Secrets → New repository secret

| Secret | How to get it |
| --- | --- |
| `TELEGRAM_BOT_TOKEN` | Message `@BotFather` on Telegram → `/newbot` → copy the token |
| `TELEGRAM_CHAT_ID` | Message `@userinfobot` on Telegram → copy the `Id` field |

## First-time setup checklist

1. Fork or clone the repository to your GitHub account.
2. Set the `REMINDER_HOUR` variable (optional — defaults to `09`).
3. Create a Telegram bot via `@BotFather` and copy the token.
4. Get your chat ID from `@userinfobot`.
5. Add `TELEGRAM_BOT_TOKEN` and `TELEGRAM_CHAT_ID` as repository secrets.
6. Go to Actions → Weekday tmux reminder → Run workflow to verify
   a Telegram message arrives and an issue is created.

## Telegram message format

```text
🖥 tmux training — Thursday, 18 September

Day 04: Debugging Workspace

https://github.com/<owner>/tmux-trainer/issues/12
```

## Disabling the workflow

Delete or rename `weekday-reminder.yml`, or disable it under
Actions → Weekday tmux reminder → (three dots) → Disable workflow.
