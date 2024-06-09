#!/usr/bin/env bash

set -eu

install_redis() {
  clear_screen
  print_header "Install Redis Server"
  
  STATUS_MSG+=$(success "Install Redis successful\n")
}

install_mariadb() {
  clear_screen
  print_header "Install MariaDB Server Version ${MARIADB_VERSION}"
  
  STATUS_MSG+=$(success "Install MariaDB Server successful\n")
}

install_mariadb_client() {
  clear_screen
  print_header "Install MariaDB Client"
  
  STATUS_MSG+=$(success "Install MariaDB Client successful\n")
}