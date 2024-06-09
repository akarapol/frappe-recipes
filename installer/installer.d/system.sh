#!/usr/bin/env bash

set -eu

update_system() {
  clear_screen
  print_header "System update"
  
  STATUS_MSG+=$(success "System update successful\n")
}

install_library() {
  clear_screen
  print_header "Install libraries"
  
  STATUS_MSG+=$(success "Install libraries successful\n")
}