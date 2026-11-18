# shellcheck shell=bash
# cmd_menu — pick any exercise (fzf, or shell select as fallback).

cmd_menu() {
  local chosen
  chosen="$(_pick_from_list "exercise" "$(_exercise_items)")"
  [[ -z "${chosen}" ]] && return 0
  cmd_show "$(awk '{print $1}' <<< "${chosen}")"
}
