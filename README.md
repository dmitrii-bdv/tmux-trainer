# tmux-trainer

Learn tmux by doing — one short exercise each working day,
delivered as a macOS notification at 09:00.

The curriculum spans five weeks and 24 exercises. It starts
with the basics (sessions, windows, panes) and finishes with
automated workspace scripts and a timed SRE drill. After five
weeks it repeats, so skills stay sharp through repetition.

## Setup

### 1. Clone

```bash
git clone git@github.com:<YOUR_GITHUB_USER>/tmux-trainer.git
cd tmux-trainer
```

### 2. Install

```bash
make install
```

Symlinks the script into `~/.local/bin`, installs the man page,
and marks scripts executable. Requires `~/.local/bin` to exist
and be on your `PATH`. Add it to your shell config if needed:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### 3. (Optional) Shell completions

```bash
make install-completions
```

Enables `tmux-trainer <TAB>` for subcommands, day numbers, and
`--tag` values. See [docs/features.md](docs/features.md) for
shell-specific setup.

### 4. (Optional) macOS daily reminder

```bash
make install-launchd
```

Fires `tmux-trainer` at 09:00 Monday–Friday via launchd.

### Uninstall

```bash
make uninstall
```

## Quick reference

```bash
tmux-trainer           # today's exercise
tmux-trainer menu      # pick any exercise with fzf
tmux-trainer done      # mark today complete
tmux-trainer skip      # defer to spaced-repetition queue
tmux-trainer check     # verify your tmux state
tmux-trainer cheat     # shortcuts introduced so far
tmux-trainer --tag config  # filter by tag
```

## Documentation

- [docs/features.md](docs/features.md) —
  curriculum, all subcommands, tags, config, NO\_COLOR,
  completions, spaced repetition, notifications
- [docs/scripts.md](docs/scripts.md) — script reference
- [docs/github-workflow.md](docs/github-workflow.md) —
  GitHub Actions setup and Telegram configuration
