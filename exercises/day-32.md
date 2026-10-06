# Day 32 — jq Transforming Output

Goal: Reshape JSON into a target format using object construction,
tags: jq
array construction, and output format strings.

## Background

jq can build entirely new structures from existing input:

```text
{key: expr}         construct a new object
[expr1, expr2]      construct a new array
to_entries          object → [{key, value}] array
from_entries        [{key, value}] → object
@csv                array → CSV string  (needs -r)
@tsv                array → TSV string  (needs -r)
@base64             string → base64
@base64d            base64 → string
@sh                 shell-quote a string safely
```

Format strings are applied with `|`: `[.a, .b] | @csv`

## Sample data

```bash
cat > /tmp/demo.json <<'EOF'
[
  {"name":"Alice","age":30,"id":1,"secret":"abc123"},
  {"name":"Bob",  "age":24,"id":2,"secret":"xyz789"}
]
EOF
```

## Task

### Part 1 — object construction

Build a new object, picking and renaming fields:

```bash
jq '.[] | {name: .name, years: .age}'   /tmp/demo.json
jq '.[] | {username: .name, uid: .id}'  /tmp/demo.json
```

### Part 2 — array construction

Build a flat array from selected fields:

```bash
jq '.[] | [.name, .age]' /tmp/demo.json
```

### Part 3 — @csv and @tsv

Combine array construction with a format string:

```bash
jq -r '.[] | [.name, .age] | @csv' /tmp/demo.json
jq -r '.[] | [.name, .age] | @tsv' /tmp/demo.json
```

`-r` is required — format strings produce plain strings, not
JSON, so they must bypass the JSON encoder.

### Part 4 — @base64

```bash
jq -r '.[] | .secret | @base64'              /tmp/demo.json
jq -r '.[] | .secret | @base64 | @base64d'  /tmp/demo.json
```

### Part 5 — @sh

`@sh` shell-quotes a value so it is safe to interpolate:

```bash
jq -r '.[] | "echo \(.name | @sh)"' /tmp/demo.json
```

Pipe the output into `bash` to run each generated command:

```bash
jq -r '.[] | "echo \(.name | @sh)"' /tmp/demo.json | bash
```

### Part 6 — to_entries and from_entries

Convert between object and key-value array form:

```bash
echo '{"a":1,"b":2}' | jq 'to_entries'
echo '{"a":1,"b":2}' \
  | jq 'to_entries | map(.value += 10) | from_entries'
```

`to_entries` is useful when you need to iterate over both keys
and values simultaneously.

## Completion goal

1. Run `jq -r '.[] | [.name, .age] | @csv' /tmp/demo.json`
   and confirm two CSV lines appear.
2. Run `echo '{"x":1,"y":2}' | jq 'to_entries | map(.key)'`
   and get `["x","y"]`.

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
