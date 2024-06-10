#!/usr/bin/env bash

set -eu

# ************************************************************ #
# USER VARIABLES                                             #
# ************************************************************ #
GIT_VERSION=
NODE_VERSION=
PYTHON_VERSION=
MARIADB_VERSION=

BENCH_VERSION=
FRAPPE_VERSION=
INSTALL_DIR=
FRAPPE_ADMIN_PASSWORD=

DB_TYPE= # [mariadb, postgres]
DB_HOST=
DB_NAME=
DB_ROOT_USERNAME=
DB_ROOT_PASSWORD=

REPO_MODE= # [ssh, token]
REPO_URI= # your.server.domain
REPO_SSH_KEY= # /absolute/path/to/private.key
REPO_TOKEN= # username@token

# ************************************************************ #
# GLOBAL VARIABLES                                             #
# ************************************************************ #
RUNNING_DIR=$(dirname -- "${0}")
OS_NAME=$(grep "^NAME=" /etc/os-release | cut -d'=' -f2 | tr -d '"')
STATUS_MSG=
TYPE=

# ************************************************************ #
# MAIN FUNCTION                                                #
# ************************************************************ #
if [ -d "${RUNNING_DIR}" ]; then
  for file in "${RUNNING_DIR}"/installer.d/*.sh; do
    source "${file}"
  done
fi

set_color

main() {
  check_variables
  case "${TYPE}" in
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
      STATUS_MSG=$(error "Wrong value for argument --type")
      clear_screen
      exit 1
      ;;
  esac
}

if [ $# -eq 0 ]; then
  clear_screen
  error "No arguments provided!\n"
  exit 1
else
  extract_args "$@"
  if [[ -z "${TYPE}" ]]; then
    clear_screen
    error "Missing value for argument --type\n"
    exit 1
  else
    main  
  fi
  clear_screen
fi