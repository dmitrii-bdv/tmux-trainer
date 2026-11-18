#compdef tmux-trainer

# Days and tags come from the installed tool, so new exercises are picked
# up without editing this file.
_tmux_trainer() {
  local -a subcommands tags days

  subcommands=(
    'menu:pick any exercise with fzf'
    'done:mark current exercise completed'
    'skip:defer current exercise to SRS queue'
    'check:verify live tmux state'
    'cheat:print shortcut reference'
    'review:open a random completed exercise'
    'exam:timed mixed drill over completed exercises'
    'help:show built-in man page'
    'lint:validate exercise files'
    '--tag:filter exercises by tag'
    '--version:print version'
  )

  tags=( ${(f)"$(tmux-trainer --list-tags 2>/dev/null)"} )
  days=( ${(f)"$(tmux-trainer --list-days 2>/dev/null)"} )

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
