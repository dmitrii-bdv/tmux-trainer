# Day 34 — xargs Basics

Goal: Pass command output as arguments to any command using xargs
tags: xargs
default behaviour, `-n`, `-I{}`, and `-t`.

## Background

`xargs` reads items from stdin and passes them as arguments to a
command. Without a command it defaults to `echo`. Split happens
on whitespace and newlines by default.

Key flags:

```text
(no flags)   all items in one argument list
-n N         N items per command invocation
-I{}         placeholder — runs command once per item
-t           print each command before running (debug)
-L N         N lines per invocation (alternative to -n)
```

## Sample data

Create a names file used in this and later xargs exercises:

```bash
printf 'alice\nbob\ncarol\n' > /tmp/names.txt
```

## Task

### Part 1 — default behaviour

```bash
echo "one two three" | xargs echo
```

All three words are passed as a single argument list. Output:
`one two three`.

### Part 2 — one item per call with `-n 1`

```bash
printf 'a\nb\nc\n' | xargs -n 1 echo "item:"
```

xargs calls `echo "item:"` three times, once per line.

### Part 3 — placeholder with `-I{}`

```bash
printf 'alice\nbob\n' | xargs -I{} echo "Hello, {}!"
```

`{}` is substituted with each input item. Implies `-n 1`.

### Part 4 — from a file

```bash
cat /tmp/names.txt | xargs -n 1 echo "user:"
```

Or equivalently:

```bash
xargs -n 1 echo "user:" < /tmp/names.txt
```

### Part 5 — debug with `-t`

```bash
printf 'x\ny\n' | xargs -t -n 1 echo
```

`-t` prints each constructed command to stderr before running it —
useful when your pipeline produces unexpected output.

### Part 6 — lines per call with `-L`

```bash
printf 'a\nb\nc\nd\n' | xargs -L 2 echo
```

Two lines per invocation: `a b` then `c d`. `-L N` treats each
line as one item even if it contains spaces; `-n N` counts words.

## Completion goal

1. Run `printf 'alice\nbob\ncarol\n' | xargs -I{} echo "user: {}"`.
   Confirm three lines of output.
2. Run `printf 'x\ny\n' | xargs -t -n 1 echo` and verify
   `-t` prints the command on stderr before each result.
3. Confirm `/tmp/names.txt` exists.

## Check

```text
file_exists  /tmp/names.txt
```

---

## Workflow

1. Read this exercise, then practise the commands in a shell.
2. Run `tmux-trainer check` to verify your work.
3. Run `tmux-trainer done` when finished.
4. Run `tmux-trainer skip` to defer to another day.
