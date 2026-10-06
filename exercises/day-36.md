# Day 36 — xargs Safe Filename Handling

Goal: Handle filenames with spaces and special characters correctly
tags: xargs
using `-0` with `find -print0` and `printf '%s\0'`.

## Background

The default whitespace delimiter breaks on filenames containing
spaces, tabs, or newlines. The null-byte delimiter is safe for
any filename:

```text
find -print0          separates results with \0 instead of \n
xargs -0 / --null     reads \0-delimited input
printf '%s\0' ...     produces \0-delimited strings inline
```

Null bytes cannot appear in a filename on any POSIX filesystem,
making them a safe universal delimiter.

## Task

### Part 1 — reproduce the problem

Create a file with a space in its name and see the default
behaviour fail:

```bash
touch '/tmp/bad file.txt'
find /tmp -maxdepth 1 -name 'bad*' | xargs ls -l
```

xargs splits on the space — `bad` and `file.txt` become two
separate arguments that do not exist.

### Part 2 — fix with `-print0` and `-0`

```bash
find /tmp -maxdepth 1 -name 'bad*' -print0 | xargs -0 ls -l
```

The null delimiter keeps the full path intact as one argument.

### Part 3 — `printf '%s\0'` for inline lists

```bash
printf '%s\0' 'file one.txt' 'file two.txt' \
  | xargs -0 -n 1 echo "processing:"
```

Useful when you construct the list in a script rather than from
`find`.

### Part 4 — combine with `-I{}`

```bash
find /tmp -maxdepth 1 -name '*.txt' -print0 \
  | xargs -0 -I{} echo "found: {}"
```

`-0` and `-I{}` compose cleanly — each null-terminated item
becomes a single `{}` substitution.

### Part 5 — safe dry-run deletion pattern

Before any destructive operation, preview with `echo`:

```bash
find /tmp -maxdepth 1 -name 'bad*' -print0 \
  | xargs -0 -n 1 echo "would remove:"
```

Replace `echo "would remove:"` with `rm` only after confirming
the list is correct.

### Part 6 — create and verify a spaced filename

```bash
touch '/tmp/my file.txt'
find /tmp -maxdepth 1 -name 'my*' -print0 | xargs -0 ls -l
```

Confirm the listing shows the full filename with the space intact.

## Completion goal

1. Run Part 1 and observe the split error.
2. Run Part 2 and confirm `ls -l` succeeds on the spaced filename.
3. Confirm `/tmp/my file.txt` exists after Part 6.

## Check

```text
file_exists  /tmp/my file.txt
```

---

## Workflow

1. Read this exercise, then practise the commands in a shell.
2. Run `tmux-trainer check` to verify your work.
3. Run `tmux-trainer done` when finished.
4. Run `tmux-trainer skip` to defer to another day.
