#!/bin/bash
# Converted from shell PS1 configuration
# Original PS1: \[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\]
# Format: [user@hostname directory] with green brackets and white directory
# Fish shell compatible (no \] escape sequences)

input=$(cat)

# Check jq availability
HAS_JQ=0
if command -v jq >/dev/null 2>&1; then
  HAS_JQ=1
fi

# Extract data from Claude Code JSON input
if [ "$HAS_JQ" -eq 1 ]; then
  current_dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "unknown"' 2>/dev/null)
  project_dir=$(echo "$input" | jq -r '.workspace.project_dir // empty' 2>/dev/null)
  version=$(echo "$input" | jq -r '.version // empty' 2>/dev/null)
  model_name=$(echo "$input" | jq -r '.model.display_name // "Claude"' 2>/dev/null)
  context_remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty' 2>/dev/null)

  # Check for extended thinking mode from the JSON input (if available)
  think_enabled=$(echo "$input" | jq -r '.extended_thinking // empty' 2>/dev/null)

  # Extract token counts (try multiple possible field names)
  total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // .tokens.input // .input_tokens // empty' 2>/dev/null)
  total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // .tokens.output // .output_tokens // empty' 2>/dev/null)
  context_window_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty' 2>/dev/null)

  # Extract duration
  total_duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // empty' 2>/dev/null)

  # Extract todos count
  todos_count=$(echo "$input" | jq -r '.todos | length // .todo_count // empty' 2>/dev/null)

  # Extract last tool used
  last_tool=$(echo "$input" | jq -r '.last_tool // .last_tool_used // .recent_tool // empty' 2>/dev/null)

  # Extract skills count
  skills_count=$(echo "$input" | jq -r '.skills | length // .skills_count // .enabled_skills | length // empty' 2>/dev/null)
else
  # Bash fallback
  current_dir=$(echo "$input" | grep -o '"workspace"[[:space:]]*:[[:space:]]*{[^}]*"current_dir"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"current_dir"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' | sed 's/\\\\/\//g')
  [ -z "$current_dir" ] && current_dir=$(echo "$input" | grep -o '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' | sed 's/\\\\/\//g')
  [ -z "$current_dir" ] && current_dir="unknown"
  model_name=$(echo "$input" | grep -o '"model"[[:space:]]*:[[:space:]]*{[^}]*"display_name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"display_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
  [ -z "$model_name" ] && model_name="Claude"
  context_remaining=""
  think_enabled=""
  total_input=""
  total_output=""
  todos_count=""
  last_tool=""
  skills_count=""
  context_window_size=""
  total_duration_ms=""
  project_dir=""
  version=""
fi

# Also check CLAUDE_THINK environment variable as fallback
if [ -z "$think_enabled" ] && [ -n "$CLAUDE_THINK" ]; then
  think_enabled="$CLAUDE_THINK"
fi

# Format token count for readability (e.g., 12500 -> "12.5k")
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

# Format individual token counts
input_tokens_fmt=$(format_tokens "$total_input")
output_tokens_fmt=$(format_tokens "$total_output")
ctx_size_fmt=$(format_tokens "$context_window_size")

# Format duration (ms -> s)
format_duration() {
  local ms=$1
  if [ -z "$ms" ] || [ "$ms" == "null" ]; then echo ""; return; fi
  awk "BEGIN {printf \"%.1fs\", $ms/1000}"
}
duration_fmt=$(format_duration "$total_duration_ms")

# Truncate last tool name if too long
if [ -n "$last_tool" ] && [ "${#last_tool}" -gt 12 ]; then
  last_tool="${last_tool:0:12}…"
fi

# Get directory basename (like \W in PS1)
dir_basename=$(basename "$current_dir")

# Get project basename (only if different from current dir)
project_basename=""
if [ -n "$project_dir" ] && [ "$project_dir" != "$current_dir" ]; then
  project_basename=$(basename "$project_dir")
fi

# Get git branch and status if in a git repo
git_branch=""
git_status_icons=""
if git rev-parse --git-dir >/dev/null 2>&1; then
  git_branch=$(git branch --show-current 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

  # Check for unstaged changes (dirty)
  if ! git diff --quiet 2>/dev/null; then
    git_status_icons="${git_status_icons}*"
  fi

  # Check for staged changes
  if ! git diff --cached --quiet 2>/dev/null; then
    git_status_icons="${git_status_icons}+"
  fi

  # Check ahead/behind remote (skip if no upstream)
  upstream=$(git rev-parse --abbrev-ref @{upstream} 2>/dev/null)
  if [ -n "$upstream" ]; then
    ahead=$(git rev-list --count @{upstream}..HEAD 2>/dev/null)
    behind=$(git rev-list --count HEAD..@{upstream} 2>/dev/null)

    if [ "$ahead" -gt 0 ]; then
      git_status_icons="${git_status_icons}↑"
    fi

    if [ "$behind" -gt 0 ]; then
      git_status_icons="${git_status_icons}↓"
    fi
  fi
fi

# Print status line matching PS1 format: [user@hostname directory] + model + context
# Green brackets, white directory (matching original PS1 colors)
printf '\033[01;32m[%s@%s\033[01;37m 📁 %s\033[01;32m]\033[00m ' "$(whoami)" "$(hostname -s)" "$dir_basename"

# Add project dir if different from current dir (orange folder)
if [ -n "$project_basename" ]; then
  printf '\033[38;5;208m📂 %s\033[0m ' "$project_basename"
fi

# Add git branch with status icons if available (soft green)
if [ -n "$git_branch" ]; then
  printf '\033[38;5;150m(%s' "$git_branch"
  if [ -n "$git_status_icons" ]; then
    printf '\033[38;5;214m%s' "$git_status_icons"  # orange for status icons
  fi
  printf '\033[38;5;150m)\033[0m '
fi

# Add version if available (dim gray)
if [ -n "$version" ]; then
  printf '\033[38;5;240mv%s\033[0m ' "$version"
fi

# Add model name (light purple)
printf '\033[38;5;147m%s\033[0m' "$model_name"

# Add think mode indicator if enabled (cyan brain icon)
if [ -n "$think_enabled" ] && [ "$think_enabled" != "false" ]; then
  printf ' \033[38;5;51m🧠\033[0m'
fi

# Add duration if available (light gray)
if [ -n "$duration_fmt" ]; then
  printf ' \033[38;5;245m⏱%s\033[0m' "$duration_fmt"
fi

# Add input/output tokens if available (light blue)
if [ -n "$input_tokens_fmt" ]; then
  printf ' \033[38;5;117m📥%s\033[0m' "$input_tokens_fmt"
fi
if [ -n "$output_tokens_fmt" ]; then
  printf ' \033[38;5;81m📤%s\033[0m' "$output_tokens_fmt"
fi

# Add context window size if available (cyan)
if [ -n "$ctx_size_fmt" ]; then
  printf ' \033[38;5;87m📊%s\033[0m' "$ctx_size_fmt"
fi

# Add todos count if available (yellow clipboard)
if [ -n "$todos_count" ] && [ "$todos_count" -gt 0 ]; then
  printf ' \033[38;5;220m📋%s\033[0m' "$todos_count"
fi

# Add last tool used if available (magenta arrow)
if [ -n "$last_tool" ]; then
  printf ' \033[38;5;213m→%s\033[0m' "$last_tool"
fi

# Add skills count if available (cyan lightning)
if [ -n "$skills_count" ] && [ "$skills_count" -gt 0 ]; then
  printf ' \033[38;5;87m⚡%s\033[0m' "$skills_count"
fi

# Add context remaining if available (color-coded)
if [ -n "$context_remaining" ]; then
  # Color based on remaining percentage
  if [ "$context_remaining" -le 20 ]; then
    printf ' \033[38;5;203m%d%%\033[0m' "$context_remaining"  # coral red
  elif [ "$context_remaining" -le 40 ]; then
    printf ' \033[38;5;215m%d%%\033[0m' "$context_remaining"  # peach
  else
    printf ' \033[38;5;158m%d%%\033[0m' "$context_remaining"  # mint green
  fi
fi

# Get memory usage of parent Claude process (RSS in MB)
claude_mem=""
if [ -n "$PPID" ]; then
  # Get RSS in KB from parent process, convert to MB
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

# Add memory usage if available (light orange)
if [ -n "$claude_mem" ]; then
  printf ' \033[38;5;216m🐏%s\033[0m' "$claude_mem"
fi

printf '\n'
