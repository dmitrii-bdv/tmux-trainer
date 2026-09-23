#compdef tmux-trainer

_tmux_trainer() {
  local -a subcommands tags days

  subcommands=(
    'menu:pick any exercise with fzf'
    'done:mark current exercise completed'
    'skip:defer current exercise to SRS queue'
    'check:verify live tmux state'
    'cheat:print shortcut reference'
    'review:open a random completed exercise'
    'help:show built-in man page'
    '--tag:filter exercises by tag'
  )

  tags=(
    sessions windows panes layouts copy-mode navigation
    config status-bar scripting workflow recovery sync
  )

  days=( {1..24} )

  case "${words[2]}" in
    --tag)
      _describe 'tag' tags
      return ;;
    check|skip)
      _describe 'day' days
      return ;;
    cheat)
      _arguments '--all[show all exercises regardless of today]'
      return ;;
  esac

  _describe 'subcommand or day' subcommands -- days
}

_tmux_trainer
