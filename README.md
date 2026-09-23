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

### 2. Make scripts executable

```bash
chmod +x scripts/tmux-trainer scripts/install-launchd
```

### 3. Add to PATH

Symlink the script into `~/.local/bin` so you can run
`tmux-trainer` from any directory. The script resolves symlinks
at runtime, so it always finds its exercises regardless of how
it is invoked.

Run from the repo root (assumes `~/.local/bin` exists and is
on PATH):

```bash
ln -sf "$(pwd)/scripts/tmux-trainer" ~/.local/bin/tmux-trainer
```

Then ensure `~/.local/bin` is on your PATH. For zsh, add to
your `~/.zshrc` (or `~/.config/zsh/.zshrc`):

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Reload and verify:

```bash
source ~/.zshrc
which tmux-trainer
```

### 4. Run manually

```bash
tmux-trainer          # today's exercise
tmux-trainer menu     # pick any exercise with fzf
tmux-trainer done     # mark today complete
tmux-trainer skip     # defer to spaced-repetition queue
tmux-trainer check    # verify your tmux state
tmux-trainer cheat    # shortcuts introduced so far
```

### 5. Install the daily macOS reminder

```bash
./scripts/install-launchd
```

### 6. Test the scheduled job

```bash
launchctl kickstart -k gui/$(id -u)/com.local.tmux-trainer
```

### 7. Uninstall

```bash
launchctl bootout gui/$(id -u) \
  ~/Library/LaunchAgents/com.local.tmux-trainer.plist
rm ~/Library/LaunchAgents/com.local.tmux-trainer.plist
```

## Documentation

- [docs/features.md](docs/features.md) —
  curriculum, exercise format, all subcommands, progress
  tracking, spaced repetition, notifications
- [docs/scripts.md](docs/scripts.md) —
  script reference: `tmux-trainer` and `install-launchd`
- [docs/github-workflow.md](docs/github-workflow.md) —
  GitHub Actions setup and Telegram configuration
