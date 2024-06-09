#!/usr/bin/env bash

set -eu

install_git() {
  clear_screen
  print_header "Install GIT Version ${GIT_VERSION}"

  STATUS_MSG+=$(success "Install GIT successful\n")
}

install_nvm() {
  clear_screen
  print_header "Install NVM"
    
  STATUS_MSG+=$(success "Install NVM successful\n")
}

install_python() {
  clear_screen
  print_header "Install PYTHON Version ${PYTHON_VERSION}"
  
  STATUS_MSG+=$(success "Install PYTHON successful\n")
}