_tmux_trainer() {
  local cur prev
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  local subcommands="menu done skip check cheat review help --tag"
  local tags="sessions windows panes layouts copy-mode navigation \
config status-bar scripting workflow recovery sync"
  local days
  days="$(seq 1 24 | tr '\n' ' ')"

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
