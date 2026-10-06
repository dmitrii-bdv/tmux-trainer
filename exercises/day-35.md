# Day 35 — xargs Parallel Execution

Goal: Fan out a slow command across many inputs in parallel using
tags: xargs
`-P` instead of writing a sequential shell loop.

## Background

`-P N` runs up to N invocations simultaneously. Combine with
`-n 1` (one item per call) for maximum parallelism. Output from
parallel jobs may interleave — redirect per-job output to separate
files if order matters. `--max-procs` is the long form of `-P`.
`-P 0` means unlimited (one worker per input item).

```text
-P N    up to N concurrent invocations
-P 0    unlimited (one per item)
-n 1    one item per call — pair with -P for fan-out
```

## Task

### Part 1 — sequential baseline

```bash
time seq 5 | xargs -n 1 -I{} bash -c 'sleep 0.2; echo done {}'
```

Five calls run one after another — total ~1 second. Note the order
is always 1 → 2 → 3 → 4 → 5.

### Part 2 — parallel with `-P 5`

```bash
time seq 5 | xargs -P 5 -n 1 -I{} bash -c 'sleep 0.2; echo done {}'
```

All five calls start simultaneously — total ~0.2 seconds. The
output order is non-deterministic.

Compare the two `time` outputs to confirm the speedup.

### Part 3 — unlimited parallelism with `-P 0`

```bash
seq 10 | xargs -P 0 -n 1 -I{} echo "running {}"
```

One worker per item. Safe for cheap commands; dangerous for
resource-heavy ones (e.g. large curl downloads).

### Part 4 — redirect per-job output

When parallel output would interleave, write each job to its
own file:

```bash
seq 3 | xargs -P 3 -n 1 -I{} \
  bash -c 'echo "job {}" > /tmp/job-{}.txt'
cat /tmp/job-1.txt /tmp/job-2.txt /tmp/job-3.txt
```

### Part 5 — parallel curl (safe, public)

```bash
printf 'tmux/tmux\njqlang/jq\nbash-git-prompt/bash-git-prompt\n' \
  | xargs -P 3 -n 1 -I{} \
    bash -c 'curl -s "https://api.github.com/repos/{}" \
      | jq -r "\"\\(.name): \\(.stargazers_count) stars\""'
```

Three API calls run concurrently. Output lines may arrive out
of order.

## Completion goal

1. Run the sequential and parallel `time` commands (Parts 1–2).
   Confirm parallel is ~5× faster.
2. Run Part 4 and confirm `/tmp/job-1.txt` contains `job 1`.

## Check

```text
file_exists  /tmp/job-1.txt
```

---

## Workflow

1. Read this exercise, then practise the commands in a shell.
2. Run `tmux-trainer check` to verify your work.
3. Run `tmux-trainer done` when finished.
4. Run `tmux-trainer skip` to defer to another day.
