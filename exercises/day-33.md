# Day 33 — jq Real-World Pipelines

Goal: Slot jq into shell pipelines with curl, aws, kubectl, and
tags: jq scripting
docker to extract exactly what you need from API responses.

## Background

In DevOps workflows jq is the glue between JSON-emitting CLIs
and the next command. Three patterns cover most cases:

```text
pipe CLI output in      aws ... --output json | jq '...'
use -r for strings      jq -r '.field' | xargs ...
fallback with //        .email // "none"
```

The `//` alternative operator returns the right side when the
left side is `null` or `false` — guarding against missing fields.

## Task

### Part 1 — curl + jq

Fetch public JSON from the GitHub API:

```bash
curl -s 'https://api.github.com/repos/tmux/tmux' \
  | jq '{name: .name,
         stars: .stargazers_count,
         lang:  .language}'
```

### Part 2 — aws + jq

List ECS cluster ARNs (read-only):

```bash
aws ecs list-clusters --output json \
  | jq -r '.clusterArns[]'
```

`--output json` is required — the AWS CLI defaults to text
format, which jq cannot parse.

If you have no ECS clusters, substitute:

```bash
aws ec2 describe-regions --output json \
  | jq -r '.Regions[].RegionName'
```

### Part 3 — kubectl + jq

List pod names in the current namespace:

```bash
kubectl get pods -o json \
  | jq -r '.items[].metadata.name'
```

List pods with their status, one per line:

```bash
kubectl get pods -o json \
  | jq -r '.items[]
      | [.metadata.name, .status.phase] | @tsv'
```

### Part 4 — docker + jq

`docker image ls --format json` outputs one JSON object per
line (NDJSON), not an array. jq processes each line as a
separate document — no `.[]` needed:

```bash
docker image ls --format json \
  | jq -r '[.Repository, .Tag, .Size] | @tsv'
```

### Part 5 — combine with xargs

Fan out a jq result as arguments to another command:

```bash
aws ecs list-clusters --output json \
  | jq -r '.clusterArns[]' \
  | xargs -I{} aws ecs describe-clusters --clusters {}
```

Each ARN becomes a separate `describe-clusters` call.

### Part 6 — fallback with //

Guard against missing or null fields:

```bash
echo '{"name":"Bob"}' \
  | jq -r '.email // "no-email"'

jq -r '.[] | .email // "no-email"' /tmp/demo.json
```

## Completion goal

1. Run the curl pipeline (Part 1) and confirm the output has
   `name`, `stars`, and `lang` fields.
2. Run the fallback example (Part 6) and confirm the missing
   field prints `no-email` rather than `null`.

## Check

```text
file_exists  /tmp/demo.json
```

---

## Workflow

1. Read this exercise, then practise the commands in a shell.
2. Run `tmux-trainer check` to verify your work.
3. Run `tmux-trainer done` when finished.
4. Run `tmux-trainer skip` to defer to another day.
