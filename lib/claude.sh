# Shared helpers for the hooks that call the `claude` CLI (`pre-commit.d/01-claude-review` and
# `prepare-commit-msg`). Sourced, not executed.
#
# These hooks spend the committer's Claude usage, so they are opt-in. Enable them with either
#   export GALACTICUS_CLAUDE_HOOKS=1                    # this shell (or put it in your shell profile)
#   git config --global galacticus.claudeHooks true     # every repository (drop --global for just one)
# The environment variable, when set, takes precedence over the git setting, so
# GALACTICUS_CLAUDE_HOOKS=0 turns them off for one command. SKIP_CLAUDE=1 also skips them.
#
# A Claude hook never blocks a commit because of a problem with Claude itself: if `claude` or `jq`
# is missing, or the call fails or times out, the hook says so in one line and lets the commit
# proceed. Only a review that positively reports serious issues blocks the commit.

# Print a one-line note from a Claude hook on stderr.
claudeHookNote() {
  echo "$CLAUDE_HOOK_NAME: $*" >&2
}

# Return success only if the Claude hooks are enabled and can run. Says why when they are enabled
# but cannot run; stays silent when they are simply not enabled.
claudeHookEnabled() {
  local setting
  if [[ "${SKIP_CLAUDE:-0}" == "1" ]]; then
    return 1
  fi
  if [[ -n "${GALACTICUS_CLAUDE_HOOKS+set}" ]]; then
    setting="$GALACTICUS_CLAUDE_HOOKS"
  else
    setting="$(git config --get galacticus.claudeHooks 2>/dev/null || true)"
  fi
  # Lowercase with `tr`: macOS's bash 3.2 lacks ${var,,}.
  setting="$(printf '%s' "$setting" | tr '[:upper:]' '[:lower:]')"
  case "$setting" in
    1|true|yes|on) ;;
    *) return 1 ;;
  esac
  if ! command -v claude >/dev/null 2>&1; then
    claudeHookNote "skipped: the 'claude' CLI is not installed (unset GALACTICUS_CLAUDE_HOOKS or galacticus.claudeHooks to silence this)"
    return 1
  fi
  if ! command -v jq >/dev/null 2>&1; then
    claudeHookNote "skipped: 'jq' is not installed"
    return 1
  fi
  return 0
}

# Run `claude` with the given arguments, reading the prompt from stdin, under a time limit of
# CLAUDE_HOOK_TIMEOUT seconds (when the `timeout` command exists). Standard error goes to the file
# named by the first argument.
claudeHookRun() {
  local errorFile="$1"
  shift
  if command -v timeout >/dev/null 2>&1; then
    timeout "${CLAUDE_HOOK_TIMEOUT:-300}" claude "$@" 2>"$errorFile"
  else
    claude "$@" 2>"$errorFile"
  fi
}
