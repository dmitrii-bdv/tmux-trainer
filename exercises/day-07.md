# Day 7 — Copy Mode I: Scrollback

Goal: Navigate and search your terminal history without
tags: copy-mode navigation
leaving tmux.

## Task

Open a pane and generate some output:

```bash
for i in $(seq 1 50); do echo "line $i"; done
```

Enter copy mode:

```text
Ctrl-b [
```

Navigate:

```text
Arrow keys        move line by line
PgUp / PgDn       move page by page
g                 jump to top of history
G                 jump to bottom
```

Search:

```text
/                 search forward
?                 search backward
n                 next match
N                 previous match
```

Exit copy mode without copying:

```text
q   or   Escape
```

## Completion goal

Enter copy mode, scroll to the first line of the output
you generated, search for "line 2", and exit cleanly.

---

## Workflow

1. Read this exercise, then practise the commands in tmux.
2. Run `tmux-trainer check` to verify your work.
3. Run `tmux-trainer done` when finished.
4. Run `tmux-trainer skip` to defer to another day.
