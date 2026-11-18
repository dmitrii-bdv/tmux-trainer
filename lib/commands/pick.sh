# shellcheck shell=bash
# Interactive pickers shared by menu, --tag, and review.

# _pick_from_list HEADER ITEMS_NEWLINE_SEPARATED — prints chosen line
# ("PAD  TITLE") to stdout; prints nothing when cancelled.
_pick_from_list() {
  local prompt="$1" items="$2" selection="" line
  if command -v fzf >/dev/null 2>&1; then
    selection="$(printf '%s\n' "${items}" | grep . \
      | fzf --prompt="${prompt} > " --height=40% --reverse)" || true
  else
    local -a arr=()
    while IFS= read -r line; do
      [[ -n "${line}" ]] && arr+=("${line}")
    done <<< "${items}"
    echo "${prompt}:" >&2
    select selection in "${arr[@]}"; do
      [[ -n "${selection}" ]] && break
    done
  fi
  printf '%s' "${selection}"
}

_exercise_items() {  # "PAD  TITLE" for every existing exercise
  local pad
  while IFS= read -r pad; do
    printf "%s  %s\n" "${pad}" "$(_ex_title "$(_ex_file "${pad}")")"
  done < <(_existing_pads)
}
