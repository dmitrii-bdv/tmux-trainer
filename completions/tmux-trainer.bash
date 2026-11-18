# Days and tags come from the installed tool, so new exercises are picked
# up without editing this file.
_tmux_trainer() {
  local cur prev subcommands days tags
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  subcommands="menu done skip check cheat review exam help lint --tag --version"
  days="$(tmux-trainer --list-days 2>/dev/null | tr '\n' ' ')"
  tags="$(tmux-trainer --list-tags 2>/dev/null | tr '\n' ' ')"

  case "${prev}" in
    --tag)
      COMPREPLY=( $(compgen -W "${tags}" -- "${cur}") )
      return ;;
    check|skip)
      COMPREPLY=( $(compgen -W "${days}" -- "${cur}") )
      return ;;
    cheat)
      COMPREPLY=( $(compgen -W "--all" -- "${cur}") )
      return ;;
  esac

  COMPREPLY=( $(compgen -W "${subcommands} ${days}" -- "${cur}") )
}

complete -F _tmux_trainer tmux-trainer
