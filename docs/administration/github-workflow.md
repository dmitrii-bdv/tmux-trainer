# GitHub Workflow: Weekday Reminder

`weekday-reminder.yml` creates a GitHub issue each weekday at your
chosen Berlin time. It then sends the reminder to every notification
channel that is configured: Telegram, Slack, Discord, and e-mail.
Channels without credentials are skipped.

> **Status (2026-11-19):** the workflow is disabled on GitHub
> (`disabled_manually`) and does not run on schedule. Re-enable it with
> `gh workflow enable "Weekday tmux reminder" --repo <owner>/tmux-trainer`.

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
| Detect configured notification channels | Sets a true/false output per channel from its credentials; values are never printed |
| Send Telegram notification | Runs only if the Telegram channel is configured |
| Send Slack notification | Runs only if the Slack channel is configured |
| Send Discord notification | Runs only if the Discord channel is configured |
| Send e-mail notification | Runs only if the e-mail channel is configured |

Each channel step has `continue-on-error: true`. If one channel fails, its
step shows as failed, but the job still succeeds and the other channels
still run. The GitHub issue is created before any channel runs.

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

## Notification channels

Every channel is optional. A channel is on when its required variables
and secrets are set. Nothing else needs to change in the workflow.

### Where to set them

| Kind | Location |
| --- | --- |
| Variable (non-sensitive) | Settings → Secrets and variables → Actions → **Variables** |
| Secret (sensitive) | Settings → Secrets and variables → Actions → **Secrets** |

Webhook URLs contain a secret token, so they belong in **Secrets** even
though they look like plain URLs.

### Variables and secrets per channel

| Name | Kind | Channel | Purpose |
| --- | --- | --- | --- |
| `REMINDER_HOUR` | Variable | All | Berlin hour of the reminder |
| `TELEGRAM_BOT_TOKEN` | Secret | Telegram | Bot token. Needs `TELEGRAM_CHAT_ID` too |
| `TELEGRAM_CHAT_ID` | Secret | Telegram | Chat ID |
| `SLACK_WEBHOOK_URL` | Secret | Slack | Incoming webhook URL |
| `DISCORD_WEBHOOK_URL` | Secret | Discord | Webhook URL |
| `SMTP_HOST` | Variable | E-mail | SMTP server host name |
| `SMTP_PORT` | Variable | E-mail | Optional. Default `587` (STARTTLS). `465` uses implicit TLS |
| `REMINDER_EMAIL_FROM` | Variable | E-mail | Sender address |
| `REMINDER_EMAIL_TO` | Variable | E-mail | Recipient address |
| `SMTP_USERNAME` | Secret | E-mail | Optional. SMTP login, if the server needs one |
| `SMTP_PASSWORD` | Secret | E-mail | SMTP password or app password. Used with `SMTP_USERNAME` |

E-mail needs `SMTP_HOST`, `REMINDER_EMAIL_FROM`, and `REMINDER_EMAIL_TO`.
Most providers require the sender address to match the SMTP login.

### Setup per channel

#### Telegram

1. Message `@BotFather` on Telegram → `/newbot` → copy the token.
2. Message `@userinfobot` on Telegram → copy the `Id` field.
3. Add `TELEGRAM_BOT_TOKEN` and `TELEGRAM_CHAT_ID` as secrets.

#### Slack

1. Create an incoming webhook for the target channel in the Slack app
   settings.
2. Add the URL as the `SLACK_WEBHOOK_URL` secret.

#### Discord

1. In the target channel, open Edit Channel → Integrations → Webhooks
   → New Webhook, then copy the URL.
2. Add the URL as the `DISCORD_WEBHOOK_URL` secret.

#### E-mail

1. Pick an SMTP provider. Gmail and similar services need an app
   password, not the account password.
2. Add `SMTP_HOST`, `REMINDER_EMAIL_FROM`, and `REMINDER_EMAIL_TO` as
   variables. Add `SMTP_PORT` only if you do not use port `587`.
3. Add `SMTP_USERNAME` and `SMTP_PASSWORD` as secrets if the server
   requires login.

## First-time setup checklist

1. Fork or clone the repository to your GitHub account.
2. Set the `REMINDER_HOUR` variable (optional — defaults to `09`).
3. Set up at least one channel from
   [Variables and secrets per channel](#variables-and-secrets-per-channel).
4. Go to Actions → Weekday tmux reminder → Run workflow to verify that
   an issue is created and each configured channel delivers a message.

## Message format

All channels send the same content: the day, the exercise title, and
the issue URL.

```text
🖥 tmux training — Thursday, 18 September

Day 04: Debugging Workspace

https://github.com/<owner>/tmux-trainer/issues/12
```

## Disabling the workflow

Delete or rename `weekday-reminder.yml`, or disable it under
Actions → Weekday tmux reminder → (three dots) → Disable workflow.
