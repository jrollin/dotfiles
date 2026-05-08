#!/bin/bash
# Format: [user@hostname directory] with green brackets and white directory
# Fish shell compatible (no \] escape sequences)

input=$(cat)

# Extract all fields in a single jq call
if command -v jq >/dev/null 2>&1; then
  eval "$(echo "$input" | jq -r '
    def e: . // "" | tostring;
    @sh "current_dir=\(.workspace.current_dir // .cwd // "unknown" | e)",
    @sh "project_dir=\(.workspace.project_dir // "" | e)",
    @sh "version=\(.version // "" | e)",
    @sh "model_name=\(.model.display_name // "Claude" | e)",
    @sh "context_used=\(.context_window.used_percentage // "" | e)",
    @sh "total_input=\(.context_window.total_input_tokens // "" | e)",
    @sh "total_output=\(.context_window.total_output_tokens // "" | e)",
    @sh "context_window_size=\(.context_window.context_window_size // "" | e)",
    @sh "effort_level=\(.effort.level // "" | e)",
    @sh "thinking_enabled=\(.thinking.enabled // "" | e)",
    @sh "rate_5h=\(.rate_limits.five_hour.used_percentage // "" | e)",
    @sh "rate_5h_resets=\(.rate_limits.five_hour.resets_at // "" | e)",
    @sh "rate_7d=\(.rate_limits.seven_day.used_percentage // "" | e)",
    @sh "rate_7d_resets=\(.rate_limits.seven_day.resets_at // "" | e)",
    @sh "agent_name=\(.agent.name // "" | e)",
    @sh "git_worktree=\(.workspace.git_worktree // "" | e)",
    @sh "worktree_name=\(.worktree.name // "" | e)",
    @sh "worktree_branch=\(.worktree.branch // "" | e)",
    @sh "worktree_path=\(.worktree.path // "" | e)"
  ' 2>/dev/null)"
else
  # Bash fallback (minimal fields)
  current_dir=$(echo "$input" | grep -o '"workspace"[[:space:]]*:[[:space:]]*{[^}]*"current_dir"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"current_dir"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' | sed 's/\\\\/\//g')
  [ -z "$current_dir" ] && current_dir=$(echo "$input" | grep -o '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' | sed 's/\\\\/\//g')
  [ -z "$current_dir" ] && current_dir="unknown"
  model_name=$(echo "$input" | grep -o '"model"[[:space:]]*:[[:space:]]*{[^}]*"display_name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"display_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
  [ -z "$model_name" ] && model_name="Claude"
  context_used="" total_input="" total_output="" context_window_size=""
  effort_level="" thinking_enabled=""
  rate_5h="" rate_5h_resets="" rate_7d="" rate_7d_resets=""
  project_dir="" version="" agent_name="" git_worktree=""
  worktree_name="" worktree_branch="" worktree_path=""
fi

format_tokens() {
  local tokens=$1
  if [ -z "$tokens" ] || [ "$tokens" -eq 0 ] 2>/dev/null; then
    echo ""
  elif [ "$tokens" -ge 1000000 ]; then
    awk "BEGIN {printf \"%.1fM\", $tokens/1000000}"
  elif [ "$tokens" -ge 1000 ]; then
    awk "BEGIN {printf \"%.1fk\", $tokens/1000}"
  else
    echo "$tokens"
  fi
}

input_tokens_fmt=$(format_tokens "$total_input")
output_tokens_fmt=$(format_tokens "$total_output")
ctx_size_fmt=$(format_tokens "$context_window_size")

dir_basename=$(basename "$current_dir")

project_basename=""
if [ -n "$project_dir" ] && [ "$project_dir" != "$current_dir" ]; then
  project_basename=$(basename "$project_dir")
fi

# Git branch and status
git_branch=""
git_status_icons=""
if git --no-optional-locks rev-parse --git-dir >/dev/null 2>&1; then
  git_branch=$(git --no-optional-locks branch --show-current 2>/dev/null || git --no-optional-locks rev-parse --short HEAD 2>/dev/null)

  if ! git --no-optional-locks diff --quiet 2>/dev/null; then
    git_status_icons="${git_status_icons}*"
  fi
  if ! git --no-optional-locks diff --cached --quiet 2>/dev/null; then
    git_status_icons="${git_status_icons}+"
  fi

  upstream=$(git --no-optional-locks rev-parse --abbrev-ref @{upstream} 2>/dev/null)
  if [ -n "$upstream" ]; then
    ahead=$(git --no-optional-locks rev-list --count @{upstream}..HEAD 2>/dev/null)
    behind=$(git --no-optional-locks rev-list --count HEAD..@{upstream} 2>/dev/null)
    [ "$ahead" -gt 0 ] && git_status_icons="${git_status_icons}↑"
    [ "$behind" -gt 0 ] && git_status_icons="${git_status_icons}↓"
  fi
fi

# --- Output ---

printf '\033[01;32m[%s@%s\033[01;37m 📁 %s\033[01;32m]\033[00m ' "$(whoami)" "$(hostname -s)" "$dir_basename"

if [ -n "$project_basename" ]; then
  printf '\033[38;5;208m📂 %s\033[0m ' "$project_basename"
fi

# Worktree indicator (teal, before git branch)
if [ -n "$worktree_name" ]; then
  wt_label="$worktree_name"
  [ -n "$worktree_branch" ] && wt_label="$worktree_name:$worktree_branch"
  [ -n "$worktree_path" ] && wt_label="$wt_label ($worktree_path)"
  printf '\033[38;5;43m🌿%s\033[0m ' "$wt_label"
fi

if [ -n "$git_branch" ]; then
  printf '\033[38;5;150m(%s' "$git_branch"
  if [ -n "$git_status_icons" ]; then
    printf '\033[38;5;214m%s' "$git_status_icons"
  fi
  printf '\033[38;5;150m)\033[0m '
fi

if [ -n "$git_worktree" ] && [ -z "$worktree_name" ]; then
  printf '\033[38;5;43m🌿%s\033[0m ' "$git_worktree"
fi

if [ -n "$version" ]; then
  printf '\033[38;5;240mv%s\033[0m ' "$version"
fi

# Agent name (orange, before model)
if [ -n "$agent_name" ]; then
  printf '\033[38;5;208m🤖%s\033[0m ' "$agent_name"
fi

printf '\033[38;5;147m%s\033[0m' "$model_name"

if [ -n "$effort_level" ]; then
  printf ' \033[38;5;221m⚡%s\033[0m' "$effort_level"
fi

if [ "$thinking_enabled" = "true" ]; then
  printf ' \033[38;5;177m🧠\033[0m'
fi

if [ -n "$input_tokens_fmt" ]; then
  printf ' \033[38;5;117m📥%s\033[0m' "$input_tokens_fmt"
fi
if [ -n "$output_tokens_fmt" ]; then
  printf ' \033[38;5;81m📤%s\033[0m' "$output_tokens_fmt"
fi

if [ -n "$ctx_size_fmt" ]; then
  printf ' \033[38;5;87m📊%s\033[0m' "$ctx_size_fmt"
fi

if [ -n "$context_used" ]; then
  ctx_used_int=$(printf '%.0f' "$context_used" 2>/dev/null || echo "$context_used")
  if [ "$ctx_used_int" -ge 80 ] 2>/dev/null; then
    printf ' \033[38;5;203m%d%%\033[0m' "$ctx_used_int"
  elif [ "$ctx_used_int" -ge 60 ] 2>/dev/null; then
    printf ' \033[38;5;215m%d%%\033[0m' "$ctx_used_int"
  else
    printf ' \033[38;5;158m%d%%\033[0m' "$ctx_used_int"
  fi
fi

# Rate limits (Claude.ai Pro/Max only) — show only when >=50%
# Format remaining time: <60min => Nmin, <24h => Nh, else Nd
fmt_remaining() {
  local resets_at=$1 now diff
  [ -z "$resets_at" ] && return
  now=$(date +%s)
  diff=$((resets_at - now))
  [ "$diff" -le 0 ] && return
  if [ "$diff" -lt 3600 ]; then
    printf '%dmin' $((diff / 60))
  elif [ "$diff" -lt 86400 ]; then
    printf '%dh' $((diff / 3600))
  else
    printf '%dd' $((diff / 86400))
  fi
}

show_5h=0
show_7d=0
[ -n "$rate_5h" ] && awk "BEGIN {exit !($rate_5h >= 50)}" && show_5h=1
[ -n "$rate_7d" ] && awk "BEGIN {exit !($rate_7d >= 50)}" && show_7d=1

if [ "$show_5h" = 1 ] || [ "$show_7d" = 1 ]; then
  printf ' \033[38;5;245m['
  if [ "$show_5h" = 1 ]; then
    awk "BEGIN {printf \"5h:%.0f%%\", $rate_5h}"
    rem=$(fmt_remaining "$rate_5h_resets")
    [ -n "$rem" ] && printf ' (%s)' "$rem"
  fi
  [ "$show_5h" = 1 ] && [ "$show_7d" = 1 ] && printf ' '
  if [ "$show_7d" = 1 ]; then
    awk "BEGIN {printf \"7d:%.0f%%\", $rate_7d}"
    rem=$(fmt_remaining "$rate_7d_resets")
    [ -n "$rem" ] && printf ' (%s)' "$rem"
  fi
  printf ']\033[0m'
fi

printf '\n'
