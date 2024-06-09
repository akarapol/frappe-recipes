#!/usr/bin/env bash

set -eu

set_color() {
  reset="\033[0m"
  black="\033[30m"
  red="\033[31m"
  green="\033[32m"
  yellow="\033[33m"
  blue="\033[34m"
  magenta="\033[35m"
  cyan="\033[36m"
  white="\033[37m"
}

clear_screen() {
  printf "\033c${STATUS_MSG}"
  printf "${reset}\n"
}

say() {
  local msg="${1}"

  if [[ $# -eq 1 ]]; then
    printf "%s\n" ${msg}
  else
    local level="${2}"

    if [[ ! "${level}" =~ ^(info|success|warn|error) ]]; then
      color="${white}"
    fi
    
    case ${level} in
      info) color="${blue}" ;;
      success) color="${green}" ;;
      warn) color="${yellow}" ;;
      error) color="${red}" ;;
    esac
    printf "${color}${msg}${reset}\n"
  fi
}

info() {
  say "\u2139 $1" "info"
}

warning() {
  say "\u26A0 $1" "warn"
}

error() {
  say "\u274C $1" "error"
}

success() {
  say "\u2714 $1" "success"
}

print_header() {  
  printf "%s\n%s\n%s\n" \
    $(printf -- "-%.0s" {1..60}) \
    "${1}" \
    $(printf -- "-%.0s" {1..60}) \
    "\n"
}

divider() {
  say $(printf -- "-%.0s" {1..60})
}

exists() {
  hash "${1}" 2>/dev/null
}

run() {
  if exists "${1}"; then
    "${1}"
  else
    error "Command '${1}' not found"
    exit 1
  fi
}

extract_args() {
  for arg in "$@"; do

    local key="${arg%%=*}"  # Extract key (everything before =)
    local value="${arg#*=}"  # Extract value (everything after =)

    case "${key}" in
      --type) TYPE="${value}" ;;
      --install) run "${value}" ;;
    esac
  done 
}