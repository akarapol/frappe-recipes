#!/usr/bin/env bash

set -eu

# ************************************************************ #
# USER VARIABLES                                             #
# ************************************************************ #
GIT_VERSION= #"2.43.0"
NODE_VERSION= #"20.11.0"
PYTHON_VERSION= #"3.12.0"
MARIADB_VERSION= #"10.11"

DB_TYPE= #[mariadb, postgres]
DB_HOST= #"localhost"
DB_ROOT_USERNAME= #"root"
DB_ROOT_PASSWORD= #"1234"

REPO_MODE="ssh" #[ssh]
REPO_URI= #"your.server.domain"
REPO_PORT= #"22"
REPO_SSH_KEY= #"$HOME/path/to/private.key"

BENCH_VERSION= #"5.22"
FRAPPE_VERSION= #"version-15"
INSTALL_DIR= #"$HOME/opt"

INSTANCE= #"frappe-15"
APP_LIST= #"erpnext=version-15 custom_app=branch_name"

SITE= #"frappe-15.local"
SITE_DB_NAME= #"frappe-15"
SITE_ADMIN_PASSWORD= #"1234"

# ************************************************************ #
# GLOBAL VARIABLES                                             #
# ************************************************************ #
RUNNING_DIR=$(dirname -- "${0}")
OS_NAME=$(grep "^NAME=" /etc/os-release | cut -d'=' -f2 | tr -d '"')
STATUS_MSG=
TYPE=
INSTALL_ITEM=
X=

# ************************************************************ #
# MAIN FUNCTION                                                #
# ************************************************************ #
if [ -f "${RUNNING_DIR}/.env" ]; then
  source "${RUNNING_DIR}/.env"
fi

if [ -d "${RUNNING_DIR}" ]; then
  for file in "${RUNNING_DIR}"/installer.d/*.sh; do
    source "${file}"
  done
fi

set_color
check_variables

# Display help message
display_help() {

  printf "Usage: install.sh [OPTIONS] \n\n"
  printf "Arguments:\n"
  printf "  -h   Display this help message.\n"
  printf "  -i   Install specific software (python, nvm, git).\n"
  printf "  -t   Setup type (dev, aio, app, db).\n"
  printf "  -x   Run specific function (update_system, install_lazygit, etc... ).\n\n"
  printf "Examples:\n"
  printf "  ./install.sh\n"  # Display help message
  printf "  ./install.sh -i python\n"  # Install Python
  printf "  ./install.sh -t dev\n"  # Set up system in developer mode
  printf "  ./install.sh -x update_system\n"  # Install Python

  warning "**Important:** Options -i (install) and -t (type) are mutually exclusive. You can only specify one at a time.\n\n"

  exit 0
}

# Process arguments using getopts
while getopts ":hi:t:x:" opt; do
  case $opt in
    h)
      display_help
      ;;
    i)
      INSTALL_ITEM="$OPTARG"
      # Check if -m was already used
      if [[ -n "$TYPE" ]]; then
        printf "Error: Options -i and -t are mutually exclusive.\n" >&2
        display_help
        exit 1
      fi
      ;;
    t)
      TYPE="$OPTARG"
      # Check if -i was already used
      if [[ -n "$INSTALL_ITEM" ]]; then
        printf "Error: Options -i and -t are mutually exclusive.\n" >&2
        display_help
        exit 1
      fi
      ;;
    x)
      X="$OPTARG"
      "$X"
      clear_screen
      exit 1
      ;;
    \?)
      printf "Invalid option: -$OPTARG\n" >&2
      display_help
      ;;
  esac
done

# Shift arguments to remove processed options
shift $((OPTIND-1))

# Validate if either mode or install item is provided
if [[ -z "$TYPE" && -z "$INSTALL_ITEM" && -z "$X" ]]; then
  printf "Error: Missing argument. Specify either -i or -t or -x.\n" >&2
  display_help
  exit 1
fi

# Implement setup logic based on mode or installation item (replace with your specific actions)
if [[ -n "$TYPE" ]]; then
  # Handle setup
  case "$TYPE" in
    dev)
      clear_screen
      STATUS_MSG=$(print_header "Setup Frappe Dev server")
      update_system
      install_library && install_git && install_nvm && install_python
      install_redis && install_mariadb
      install_bench && install_frappe
      ;;
    aio)
      clear_screen
      STATUS_MSG=$(print_header "Setup Frappe All-in-one server")
      update_system
      install_library && install_git && install_nvm && install_python
      install_redis && install_mariadb
      install_bench && install_frappe
      ;;
    app)
      clear_screen
      STATUS_MSG=$(print_header "Setup Frappe App server")
      update_system
      install_library && install_git && install_nvm && install_python
      install_mariadb_client
      install_bench && install_frappe
      ;;
    db)
      clear_screen
      STATUS_MSG=$(print_header "Setup Frappe DB server")
      update_system
      install_redis && install_mariadb
      ;;
    *)
      clear_screen
      STATUS_MSG=$(error "Invalid setup mode: $TYPE")
      clear_screen
      exit 1
      ;;
  esac
else
  # Handle installation
  case "$INSTALL_ITEM" in
    python)
      STATUS_MSG=$(print_header "Install Python")
      install_python
      clear_screen
      ;;
    nvm)
      STATUS_MSG=$(print_header "Install NVM, npm, nodejs, yarn")
      install_nvm
      clear_screen
      ;;
    git)
      STATUS_MSG=$(print_header "Install Git")
      install_git && install_lazygit
      clear_screen
      ;;
    *)
      STATUS_MSG=$(error "Invalid software to install: $INSTALL_ITEM")
      clear_screen
      exit 1
      ;;
  esac
fi