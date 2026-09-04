# Day 16 — Multi-Repo Workspace Script

Goal: Build a workspace script that sets up multiple
repositories at once — the kind of layout you'd open
every morning.

## Task

Create `~/bin/sre-workspace`:

```bash
#!/usr/bin/env bash
set -euo pipefail

SESSION="sre"
REPOS=(
  "${HOME}/dev/infra"
  "${HOME}/dev/platform"
  "${HOME}/dev/docs"
)

tmux kill-session -t "${SESSION}" 2>/dev/null || true
tmux new-session -d -s "${SESSION}"

for i in "${!REPOS[@]}"; do
  REPO="${REPOS[$i]}"
  WIN="repo-$((i+1))"
  if [[ "${i}" -eq 0 ]]; then
    tmux rename-window -t "${SESSION}:1" "${WIN}"
  else
    tmux new-window -t "${SESSION}" -n "${WIN}"
  fi
  tmux send-keys -t "${SESSION}:${WIN}" \
    "cd '${REPO}' 2>/dev/null || echo 'not found: ${REPO}'" Enter
  tmux send-keys -t "${SESSION}:${WIN}" "git status" Enter
done

tmux select-window -t "${SESSION}:repo-1"
tmux attach -t "${SESSION}"
```

Adapt the `REPOS` array to paths that exist on your
machine.

## Completion goal

Run the script, verify each window lands in its repo
and shows git status, then kill and recreate the
session without editing the script.
