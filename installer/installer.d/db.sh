#!/usr/bin/env bash

set -eu

install_redis() {
  clear_screen
  print_header "Install Redis Server"
  
  if ! exists redis-server; then
    sudo su -c "
      apt update && apt upgrade -y &&
      apt install --no-install-recommends -y \
        redis-server &&
      apt autoclean -y && apt autoremove -y"
  fi
  STATUS_MSG+=$(success "Install Redis successful")
}

setup_mariadb_repository() {  
  STATUS_MSG+=$(success "Setup MariaDB Repository")
  sudo su -c "curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup \
    | bash -s -- --skip-maxscale --mariadb-server-version=\"mariadb-${MARIADB_VERSION}\""
}

install_mariadb() {
  clear_screen
  print_header "Install MariaDB Server"
  
  if ! exists mariadb; then
    setup_mariadb_repository

    sudo su -c "
      apt update && apt upgrade -y &&
      apt install --no-install-recommends -y \
          mariadb-server mariadb-client &&
      apt autoclean -y && apt autoremove -y"

    # Config /etc/mysql/my.cnf
    sudo su -c 'echo "
    [mysqld]
    bind-address = 0.0.0.0
    character-set-client-handshake = FALSE
    character-set-server = utf8mb4
    collation-server = utf8mb4_unicode_ci

    [mysql]
    default-character-set = utf8mb4
    " >> /etc/mysql/my.cnf'

    sudo service mariadb start  &&
    sudo mysql_secure_installation &&
    sudo service mariadb restart

    STATUS_MSG+=$(success "Install MariaDB Server successful")
  fi
}

install_mariadb_client() {
  clear_screen
  print_header "Install MariaDB Client"
  
  if ! exists mariadb; then
    setup_mariadb_repository

    sudo su -c "
      apt update && apt upgrade -y &&
      apt install --no-install-recommends -y \
          mariadb-client &&
      apt autoclean -y && apt autoremove -y"

    # Config /etc/mysql/my.cnf
    sudo su -c 'echo "
    [mysql]
    default-character-set = utf8mb4
    " >> /etc/mysql/my.cnf'
    
    STATUS_MSG+=$(success "Install MariaDB Client successful")
  fi
}