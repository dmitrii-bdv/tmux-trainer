# Day 30 — jq Basics

Goal: Extract values from any JSON document using identity, field
tags: jq
access, array index, pipe, and keys.

## Background

jq is a lightweight streaming JSON processor. You pipe JSON into
it, give it a filter expression, and it prints the result.

Core filters:

```text
.              identity — pass input through unchanged
.field         access an object key
.[0]           first array element
.[-1]          last array element
.[1:3]         slice — elements 1 and 2
|              pipe — left output feeds right input
keys           object keys, sorted alphabetically
```

jq pretty-prints by default. Add `-r` (raw) to strip quotes
from string output — essential when piping into other commands.

## Sample data

Save this file — it is used for this and the next
three exercises:

```bash
cat > /tmp/demo.json <<'EOF'
{
  "name": "Alice",
  "age": 30,
  "active": true,
  "address": { "city": "Berlin" },
  "tags": ["admin", "ops", "dev"],
  "id": 1
}
EOF
```

## Task

### Part 1 — install check

```bash
jq --version
```

If missing: `brew install jq`

### Part 2 — identity and pretty-print

```bash
jq '.' /tmp/demo.json
```

jq re-prints the whole document, indented and coloured.

### Part 3 — field access

```bash
jq '.name'         /tmp/demo.json   # → "Alice"
jq '.age'          /tmp/demo.json   # → 30
jq '.address.city' /tmp/demo.json   # → "Berlin"
```

### Part 4 — array index and slice

```bash
jq '.tags'      /tmp/demo.json   # whole array
jq '.tags[0]'   /tmp/demo.json   # first element
jq '.tags[-1]'  /tmp/demo.json   # last element
jq '.tags[0:2]' /tmp/demo.json   # slice: elements 0 and 1
```

### Part 5 — pipe

```bash
jq '.address | .city' /tmp/demo.json
```

Equivalent to `.address.city`. Pipes shine when the left side
produces multiple values that each feed into the right.

### Part 6 — keys

```bash
jq 'keys' /tmp/demo.json
```

Returns object keys sorted alphabetically as a JSON array.

### Part 7 — raw output

```bash
jq  '.name'   /tmp/demo.json   # → "Alice"  (quoted)
jq -r '.name' /tmp/demo.json   # → Alice    (no quotes)
```

Use `-r` whenever you pipe jq output to another command — the
surrounding `"` characters break most tools without it.

## Completion goal

1. Confirm `jq --version` prints a version number.
2. Run `jq '.tags[-1]' /tmp/demo.json` and get `"dev"`.
3. Run `jq -r '.name' /tmp/demo.json` and get `Alice`.

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
