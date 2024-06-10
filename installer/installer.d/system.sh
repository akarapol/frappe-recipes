#!/usr/bin/env bash

set -eu

update_system() {
  clear_screen
  print_header "System update"
  
  sudo su -c "
    apt update && apt upgrade -y &&
    apt autoclean -y && apt autoremove -y"

  STATUS_MSG+=$(success "System update successful")
}

install_library() {
  clear_screen
  print_header "Install libraries"
  
  sudo su -c "
    apt update && apt upgrade -y &&
    apt install --no-install-recommends -y \
      build-essential software-properties-common ca-certificates \
      curl wget llvm make gpg openssl sudo unzip zsh \
      libffi-dev libnss3 libnspr4 tk-dev xvfb \
      libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev &&
    apt autoclean -y && apt autoremove -y"

  STATUS_MSG+=$(success "Install libraries successful")
}