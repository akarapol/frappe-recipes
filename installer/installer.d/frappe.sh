#!/usr/bin/env bash

set -eu

install_bench() {
  clear_screen
  print_header "Install Bench Version ${BENCH_VERSION}"
  
  STATUS_MSG+=$(success "Install Bench successful")
}

install_frappe() {
  clear_screen
  print_header "Install Frappe Version ${FRAPPE_VERSION}"
  
  STATUS_MSG+=$(success "Install Frappe successful")
}