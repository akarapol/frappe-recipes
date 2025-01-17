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
  printf "\033c${STATUS_MSG}${reset}\n"
}

say() {
  local msg="${1}"

  if [[ $# -eq 1 ]]; then
    printf "\n%s" ${msg}
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
    printf "${color}${msg}${reset}"
  fi
}

info() {
  say "\n\u2139 $1" "info"
}

warning() {
  say "\n\u26A0 $1" "warn"
}

error() {
  say "\n\u274C $1" "error"
}

success() {
  say "\n\u2714 $1" "success"
}

print_header() {
    printf "%s\n%s\n%s\n" \
      $(divider) "${1}" $(divider)
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

check_variables() {
  local err_msg=$(print_header "Check Variables")
  local fail=0
  local variables=("GIT_VERSION" "NODE_VERSION" "PYTHON_VERSION" "MARIADB_VERSION")
  variables+=("DB_TYPE" "DB_HOST" "DB_ROOT_USERNAME" "DB_ROOT_PASSWORD")
  variables+=("REPO_MODE" "REPO_URI" "REPO_SSH_KEY")
  variables+=("BENCH_VERSION" "FRAPPE_VERSION" "INSTALL_DIR")
  variables+=("INSTANCE" "APP_LIST" "SITE" "SITE_DB_NAME" "SITE_ADMIN_PASSWORD")

  for variable in "${variables[@]}"; do
    if [[ -z "${!variable}" ]]; then
      err_msg+=$(error "Variable ${variable} must be defined")
      printf "\033c${err_msg}\n"
      fail=1
    fi
  done
  if [ "${fail}" == 1 ]; then exit 1; fi
}