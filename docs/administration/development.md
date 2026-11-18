# Development

How to work on tmux-trainer: set up, test, add content, and release.

## Set up

```bash
brew install bats-core shellcheck tmux jq   # macOS
sudo apt-get install -y bats shellcheck tmux jq   # Debian / Ubuntu
```

`fzf` is optional and only needed to try the interactive pickers.

## Test and lint

```bash
make test        # ShellCheck, exercise lint, Bats tests
make lint        # exercise lint only
bats tests/cli.bats   # one test file
```

CI runs the same steps (see
[`.github/workflows/ci.yml`](../../.github/workflows/ci.yml)). A change
is not ready to merge until `make test` passes.

## Add an exercise

1. Copy the closest existing file, for example `exercises/day-07.md`,
   to the next number. Numbers must be contiguous: the cycle length is
   the number of files.
2. Set the first line to `# Day N — Title`.
3. Add a `Goal:` line and a `tags:` line. Reuse existing tags so that
   `--tag` stays useful.
4. Write the Task, Completion goal, and Check sections.
5. In the `## Check` block, use one assertion per line. Quote arguments
   that contain spaces. Run `tmux-trainer lint` until it reports OK.
6. Update the exercise count in [features](../customer/features.md) if
   it is mentioned there. Help and completions update automatically.

Assertion types and argument counts are listed in
[architecture](architecture.md#checks-as-data).

## Change the code

- Keep the entry point thin. New logic goes in `lib/`, and command
  behaviour goes in `lib/commands/`.
- Add a test for every bug fix. Put unit tests in `tests/unit_libs.bats`
  and end-to-end tests in `tests/cli.bats`.
- Do not use `grep -P` in scripts or tests. macOS ships a grep without it.
- Keep lines at 80 characters or fewer in Markdown.

## Documentation rules

- `docs/administration/` is internal. Anything about infrastructure,
  secrets, or the release process goes here.
- `docs/customer/` is published. Keep it free of internal jargon,
  credentials, and infrastructure URLs.
- Markdown must pass markdownlint:

  ```bash
  markdownlint --config ~/.config/markdownlint.json docs/**/*.md README.md
  ```

## Release process

Versions follow semantic versioning:

- **Patch** (1.1.x): fixes that do not change behaviour.
- **Minor** (1.x.0): new features or new exercises that keep existing
  behaviour working.
- **Major** (x.0.0): changes to the state file formats or to the
  command interface.

Steps:

1. Set `TMUX_TRAINER_VERSION` in `lib/config.sh`.
2. Add a section to `CHANGELOG.md` with the date and the changes.
3. Open a pull request. Wait for CI to pass, then merge.
4. Tag the merge commit and create the release:

   ```bash
   git switch main && git pull --ff-only
   gh release create vX.Y.Z --target main --title "vX.Y.Z" \
     --notes-file <(sed -n '/^## vX.Y.Z/,/^## /p' CHANGELOG.md | sed '$d')
   ```

5. Check that the release shows the PolyForm licence in the sidebar
   and that `tmux-trainer --version` matches the tag after reinstalling.

## Branch protection

`main` blocks force pushes and branch deletion. Changes go through a
pull request on a feature branch.
