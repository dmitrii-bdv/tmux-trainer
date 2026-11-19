# Roadmap

Effort: [S] hours · [M] days · [L] week+

---

## Next

Priority order: quick documentation fixes first, then the verified gaps
from the competitive review (2026-11-19). Each item was checked against
the code as of v1.4.0.

1. **Accurate curriculum length** [S] — README, getting started, and
   features say "six weeks". Rotation is 41 exercises at 5 per ISO week,
   so one cycle takes about 8.2 weeks. Reword the docs.
2. **Verified completion** [S] — `cmd_done` marks an exercise complete
   without running `check`. Record "verified" when the checks pass and
   keep manual completion as a separate state.
3. **Confidence-based review queue** [M] — `_srs_update` ignores a
   correct answer on an exercise that is not already queued, so
   completed exercises are never revisited unless skipped. Give each
   completed exercise a confidence score and schedule reviews from it.
4. **Richer assertions** [M] — the nine assertion types in
   `lib/assert.sh` cannot check pane geometry, so "a 40% lower pane"
   cannot be verified. Add pane size, active pane, synchronised panes,
   session attached state, and key bindings.
5. **Isolated practice server** [M] — nothing uses `tmux -L`. `exam`
   runs in the learner's current session and creates panes there. Run
   `check` and `exam` on a dedicated socket such as `tmux -L
   tmux-trainer`.
6. **Challenge-only mode** [M] — hide commands and shortcut hints until
   the learner asks, so recall is tested instead of imitation.
7. **Curriculum tracks** [M] — split the 41 exercises into Tmux
   Fundamentals, Tmux Automation, SRE Workflows, and Shell Productivity.
   The jq and xargs exercises (days 30–37) move to Shell Productivity.
8. **macOS coverage in CI** [M] — `ci.yml` runs only on
   `ubuntu-latest`, so the launchd and osascript paths are untested.

---

## Ideas

### Progressive hints [M]

Reveal hints in steps on request, as learntmux.dev does. Not yet checked
against the exercise files; confirm the format first.

### Guided lessons with failure feedback [M]

tmux tutor gives an explicit instruction, lets the learner act in a
second terminal, and explains a failed check. Consider the same
structure for exercises that have a check block.

### Homebrew formula [L]

`brew install tmux-trainer`. Only worth pursuing once the project
has external users.

### Website version [L]

A browser version of tmux-trainer with the same exercises and an
emulated tmux terminal, so people can practise without installing
anything. Onboarding without installing is where learntmux.dev leads.
No timeline yet; the CLI stays the primary product until then.

### Licence (decided)

Keep the PolyForm Noncommercial licence. Commercial use needs a separate
agreement with the maintainer, so terms are agreed before anyone
profits from the project.

### Competitive positioning (2026-11-19)

External overall scores, 10-point scale, not benchmarked and the
competitor numbers not verified: Tmux Trainer 9, tmux tutor 8,
learntmux.dev 8, Turtle 5. The strongest points are the long-term
operational scenarios, real-state checks, and scheduled practice.

---

## Completed

### Content

- **tmux.conf fundamentals** [S] → day-29
- **Status bar progression** [M] → days 26-28
  (minimal modern, Catppuccin via TPM, DevOps dashboard)
- **jq exercises** (A–D) [M] → days 30-33
- **xargs exercises** (A–D) [M] → days 34-37
- **Plugin-aware exercises** [M] → days 38-40
  (tmux-resurrect, tmux-continuum, tmux-fingers)
- **wttr.in weather panel** [S] → day-41
  (pane lifecycle, recovery keybind, multi-city extension)

### Infrastructure

- **Webhook reminder** [M] — POSTs exercise title and goal to
  Telegram, Slack, or Discord on every run; platform detected
  from URL shape.
- **Reminder channels in GitHub workflow** [M] → v1.4.0 — Telegram,
  Slack, Discord, and e-mail, each enabled by its variables and
  secrets. See `docs/administration/github-workflow.md`.
