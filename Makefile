BIN_DIR   ?= $(HOME)/.local/bin
ZSH_COMP  ?= $(HOME)/.zsh/completions
BASH_COMP ?= /usr/local/etc/bash_completion.d

.PHONY: install install-completions install-launchd uninstall help

help:
	@echo "Targets:"
	@echo "  install             symlink script, install man page"
	@echo "  install-completions install shell completions (bash + zsh)"
	@echo "  install-launchd     install macOS launchd daily reminder"
	@echo "  uninstall           remove symlink, man page, completions"

install:
	@test -d "$(BIN_DIR)" || (echo "$(BIN_DIR) not found — create it first" && exit 1)
	ln -sf "$(CURDIR)/scripts/tmux-trainer" "$(BIN_DIR)/tmux-trainer"
	"$(CURDIR)/scripts/tmux-trainer" --man-install
	@echo "Installed → $(BIN_DIR)/tmux-trainer"

install-completions:
	@# zsh
	@mkdir -p "$(ZSH_COMP)"
	cp completions/tmux-trainer.zsh "$(ZSH_COMP)/_tmux_trainer"
	@echo "zsh completion → $(ZSH_COMP)/_tmux_trainer"
	@# bash
	@mkdir -p "$(BASH_COMP)"
	cp completions/tmux-trainer.bash "$(BASH_COMP)/tmux-trainer"
	@echo "bash completion → $(BASH_COMP)/tmux-trainer"
	@echo "Reload your shell or run: source $(BASH_COMP)/tmux-trainer"

install-launchd:
	"$(CURDIR)/scripts/install-launchd"

uninstall:
	rm -f "$(BIN_DIR)/tmux-trainer"
	rm -f "$(HOME)/.local/share/man/man1/tmux-trainer.1"
	rm -f "$(ZSH_COMP)/_tmux_trainer"
	rm -f "$(BASH_COMP)/tmux-trainer"
	@echo "Uninstalled."
