# Day 37 — xargs Real-World Pipelines

Goal: Replace slow sequential shell loops with composable pipelines
tags: xargs scripting
combining xargs with jq, aws, kubectl, docker, and git.

## Background

A `for` loop that calls a CLI once per item is the slowest pattern
in DevOps scripting. `xargs -P` turns it into a parallel fan-out.
The pattern is always:

```text
produce list   jq -r / awk / CLI --output json
  |
null-separate  -print0 / printf '%s\0'   (if filenames)
  |
xargs [-0] [-P N] -I{} command {}
```

**macOS note:** macOS ships BSD xargs. `-r` (skip empty input) is
GNU-only. Use `| grep . | xargs` to guard against empty input on
BSD, or install GNU coreutils with `brew install coreutils`.

## Task

### Part 1 — jq + xargs

Extract values from JSON and act on each:

```bash
echo '[{"repo":"tmux"},{"repo":"jq"}]' \
  | jq -r '.[].repo' \
  | xargs -n 1 -I{} \
    echo "would clone: git@github.com:owner/{}.git"
```

Replace `echo "would clone:"` with `git clone` to make it real.

### Part 2 — aws + xargs

Describe multiple ECS clusters in parallel (read-only):

```bash
aws ecs list-clusters --output json \
  | jq -r '.clusterArns[]' \
  | xargs -P 4 -n 1 -I{} \
    aws ecs describe-clusters --clusters {}
```

If you have no ECS clusters, substitute:

```bash
aws ec2 describe-regions --output json \
  | jq -r '.Regions[].RegionName' \
  | xargs -P 4 -n 1 -I{} \
    aws ec2 describe-availability-zones --region {}
```

### Part 3 — kubectl + xargs (dry run)

Preview a bulk restart without executing it:

```bash
kubectl get deployments -o json \
  | jq -r '.items[].metadata.name' \
  | xargs -n 1 echo "would restart:"
```

Remove `echo "would restart:"` and replace with
`kubectl rollout restart deployment` to make it live.

### Part 4 — docker + xargs

Remove all exited containers:

```bash
docker ps -a --filter status=exited --format '{{.ID}}' \
  | grep . \
  | xargs docker rm
```

`grep .` guards against empty input (BSD-safe alternative to
GNU `-r`). Safe to run — only touches exited containers.

### Part 5 — git + xargs

Bulk-pull every repo under `~/git/` in parallel:

```bash
ls ~/git/ \
  | xargs -P 4 -I{} git -C ~/git/{} pull --ff-only
```

`git -C path` runs git against the given directory without `cd`.
`--ff-only` aborts rather than creating a merge commit.

### Part 6 — loop vs xargs benchmark

```bash
# sequential loop — ~1 second
time for i in $(seq 5); do sleep 0.2; done

# parallel xargs — ~0.2 seconds
time seq 5 | xargs -P 5 -n 1 -I{} sleep 0.2
```

The xargs version is ~5× faster for I/O-bound work.

## Completion goal

1. Run Part 1 and confirm two `would clone:` lines appear.
2. Run the benchmark (Part 6) and confirm parallel is faster.
3. Confirm `/tmp/names.txt` exists (created in Day 34).

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
