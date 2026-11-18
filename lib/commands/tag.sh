# shellcheck shell=bash
# cmd_tag NAME — list exercises with a tag; open directly if only one.

cmd_tag() {
  local tag="${1:-}" pad file items="" count chosen
  if [[ -z "${tag}" ]]; then
    echo "Usage: tmux-trainer --tag <name>" >&2; return 1
  fi

  while IFS= read -r pad; do
    file="$(_ex_file "${pad}")"
    if _ex_has_tag "${file}" "${tag}"; then
      items+="${pad}  $(_ex_title "${file}")"$'\n'
    fi
  done < <(_existing_pads)

  if [[ -z "${items}" ]]; then
    printf "No exercises tagged '%s'\n" "${tag}" >&2; return 1
  fi

  count="$(grep -c . <<< "${items}")"
  if [[ "${count}" -eq 1 ]]; then
    cmd_show "$(awk '{print $1}' <<< "${items}")"
    return 0
  fi

  chosen="$(_pick_from_list "[${tag}]" "${items}")"
  [[ -z "${chosen}" ]] && return 0
  cmd_show "$(awk '{print $1}' <<< "${chosen}")"
}
