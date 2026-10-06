# Day 31 — jq Selecting and Filtering

Goal: Filter arrays and objects by predicate using select, map,
tags: jq
has, and type guards.

## Background

`select(expr)` passes a value through only when `expr` is true —
everything else is dropped. `map(f)` applies filter `f` to every
element of an array, returning a new array. Type guards keep
only values of the named type.

```text
.[] | select(.age > 25)    iterate, keep matching items
map(.name)                 apply filter to every element
map(select(.active))       filter-inside-map pattern
has("key")                 true if object has the key
any(.[]; .active)          true if any element matches
all(.[]; .age > 18)        true if all elements match
```

## Sample data

Overwrite `/tmp/demo.json` with a user array:

```bash
cat > /tmp/demo.json <<'EOF'
[
  {"name":"Alice","age":30,"active":true,
   "email":"alice@example.com","id":1},
  {"name":"Bob",  "age":24,"active":false,"id":2},
  {"name":"Carol","age":35,"active":true,
   "email":"carol@example.com","id":3}
]
EOF
```

## Task

### Part 1 — select

Iterate the array with `.[]`, then filter each element:

```bash
jq '.[] | select(.age > 25)'        /tmp/demo.json
jq '.[] | select(.active == true)'  /tmp/demo.json
```

### Part 2 — map

Apply a filter to every element and return an array:

```bash
jq 'map(.name)'    /tmp/demo.json
jq 'map(.age + 1)' /tmp/demo.json
```

### Part 3 — map + select

The most common pattern — filter an array in place:

```bash
jq 'map(select(.active))'         /tmp/demo.json
jq 'map(select(.age >= 30))'      /tmp/demo.json
```

### Part 4 — type guards

Keep only elements of a given type:

```bash
echo '[1, "a", [], {}, true]' | jq '.[] | numbers'
echo '[1, "a", [], {}, true]' | jq '.[] | strings'
echo '[1, "a", [], {}, true]' | jq '.[] | arrays'
```

### Part 5 — has

Filter objects that contain (or lack) a specific key:

```bash
jq 'map(select(has("email")))'        /tmp/demo.json
jq 'map(select(has("email") | not))' /tmp/demo.json
```

### Part 6 — any and all

Test the whole array in a single expression:

```bash
jq 'any(.[]; .active)'   /tmp/demo.json   # true
jq 'all(.[]; .age > 18)' /tmp/demo.json   # true
jq 'all(.[]; .active)'   /tmp/demo.json   # false
```

## Completion goal

1. Run `jq 'map(select(.active))' /tmp/demo.json` and confirm
   only Alice and Carol appear.
2. Run `jq 'map(select(has("email")))' /tmp/demo.json` and
   confirm Bob is excluded.
3. Run `jq 'any(.[]; .active)' /tmp/demo.json` and get `true`.

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
