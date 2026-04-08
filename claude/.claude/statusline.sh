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
    @sh "context_remaining=\(.context_window.remaining_percentage // "" | e)",
    @sh "total_input=\(.context_window.total_input_tokens // "" | e)",
    @sh "total_output=\(.context_window.total_output_tokens // "" | e)",
    @sh "context_window_size=\(.context_window.context_window_size // "" | e)",
    @sh "total_duration_ms=\(.cost.total_duration_ms // "" | e)",
    @sh "agent_name=\(.agent.name // "" | e)",
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
  context_remaining="" total_input="" total_output="" context_window_size=""
  total_duration_ms="" project_dir="" version="" agent_name="" worktree_name="" worktree_branch="" worktree_path=""
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

duration_fmt=""
if [ -n "$total_duration_ms" ] && [ "$total_duration_ms" != "null" ]; then
  duration_fmt=$(awk "BEGIN {printf \"%.1fs\", $total_duration_ms/1000}")
fi

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

if [ -n "$version" ]; then
  printf '\033[38;5;240mv%s\033[0m ' "$version"
fi

# Agent name (orange, before model)
if [ -n "$agent_name" ]; then
  printf '\033[38;5;208m🤖%s\033[0m ' "$agent_name"
fi

printf '\033[38;5;147m%s\033[0m' "$model_name"

if [ -n "$duration_fmt" ]; then
  printf ' \033[38;5;245m⏱%s\033[0m' "$duration_fmt"
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

if [ -n "$context_remaining" ]; then
  if [ "$context_remaining" -le 20 ]; then
    printf ' \033[38;5;203m%d%%\033[0m' "$context_remaining"
  elif [ "$context_remaining" -le 40 ]; then
    printf ' \033[38;5;215m%d%%\033[0m' "$context_remaining"
  else
    printf ' \033[38;5;158m%d%%\033[0m' "$context_remaining"
  fi
fi

# Process memory usage
claude_mem=""
if [ -n "$PPID" ]; then
  rss_kb=$(ps -o rss= -p "$PPID" 2>/dev/null | tr -d ' ')
  if [ -n "$rss_kb" ] && [ "$rss_kb" -gt 0 ] 2>/dev/null; then
    rss_mb=$((rss_kb / 1024))
    if [ "$rss_mb" -ge 1024 ]; then
      claude_mem=$(awk "BEGIN {printf \"%.1fG\", $rss_mb/1024}")
    else
      claude_mem="${rss_mb}M"
    fi
  fi
fi
if [ -n "$claude_mem" ]; then
  printf ' \033[38;5;216m🐏%s\033[0m' "$claude_mem"
fi

printf '\n'
