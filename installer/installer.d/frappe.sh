#!/usr/bin/env bash

set -eu

REPO_ADDR=

confirm(){     
  while true;
  do
    read -p "Please type '$1' to confirm: " name
    
    if [ "${name}" = "$1" ]; then
        break;
    fi
    error "Invalid!!!, Try again\n"
  done  
}

install_playwright() {
  playwright library
  sudo su -c "
    apt install --no-install-recommends -y \
        libatk1.0-0 libatk-bridge2.0-0 libcups2 libxkbcommon0 libxcomposite1 \
        libxrandr2 libgbm1 libpango-1.0-0 libcairo2 libasound2 libatspi2.0-0 &&
    apt autoclean -y"    
}

install_bench() {
  clear_screen
  print_header "Install Bench Version ${BENCH_VERSION}"
  
  if ! exists bench; then
    # frappe needed library       
    sudo su -c "
      apt update && apt upgrade -y &&      
      apt install --no-install-recommends -y \
          xvfb libfontconfig wkhtmltopdf &&
      apt autoclean -y && apt autoremove -y"

    # additional library
    sudo su -c "
      apt install --no-install-recommends -y \
        libzbar0
      apt autoclean -y && apt autoremove -y"
      
    pip install frappe-bench=="${BENCH_VERSION}"
    sudo pip install frappe-bench=="${BENCH_VERSION}"
  fi
  STATUS_MSG+=$(success "Install Bench successful")
}

setup_repo() {
  if [ "${REPO_MODE}" = "ssh" ]; then

    if ! grep -iq "Host frappe-repo" ~/.ssh/config; then
      printf "\n%s\n%s\n%s\n%s\n%s\n" \
        "HOST frappe-repo" \
        " HostName ${REPO_URI}" \
        " Port ${REPO_PORT}" \
        " User git" \
        " IdentityFile ${REPO_SSH_KEY}" |
        tee -a ~/.ssh/config >/dev/null  
    fi
    
    REPO_ADDR=ssh://frappe-repo/frappe
  fi

  if [ "$REPO_MODE" = "https" ]; then
    REPO_ADDR=https://$REPO_TOKEN@$REPO_URI/frappe
  fi
  STATUS_MSG+=$(success "Setup Frappe repository")

}

create_instance() {
  print_header "Create new instance ${INSTANCE} in ${INSTALL_DIR}"

  bench init "${INSTALL_DIR}/${INSTANCE}" \
              --frappe-branch "${FRAPPE_VERSION}" \
              --frappe-path "${REPO_ADDR}/frappe" \
              --verbose &&
  cd "${INSTALL_DIR}/${INSTANCE}" &&
  chmod -R o+rx "${INSTALL_DIR}/${INSTANCE}"
  STATUS_MSG+=$(success "Create instance ${INSTANCE} in ${INSTALL_DIR}")
}

create_site() {
  print_header "Setup site >> ${SITE}"

  cd "${INSTALL_DIR}/${INSTANCE}" &&
  bench new-site "${SITE}" \
                --no-mariadb-socket \
                --db-host "${DB_HOST}" \
                --db-root-username "${DB_ROOT_USERNAME}" \
                --db-root-password "${DB_ROOT_PASSWORD}" \
                --db-name "${SITE_DB_NAME}" \
                --admin-password "${SITE_ADMIN_PASSWORD}" \
                --verbose &&
  bench --site "${SITE}" add-to-hosts
  STATUS_MSG+=$(success "Create site ${SITE} for instance ${INSTANCE}")
}

install_app() {
  cd "${INSTALL_DIR}/${INSTANCE}"

  for app in ${APP_LIST}; do
    local app_name="${app%%=*}"  # Extract key (everything before =)
    local app_branch="${app#*=}"  # Extract value (everything after =)
    
    bench get-app "{app_name}" "${REPO_ADDR}/${app_name}" --branch ${app_branch} &&
    bench --site "${SITE}" install-app "${app_name}"
  	STATUS_MSG+=$(success "Install app ${app_name} branch ${app_branch}")
  done
}

enable_prod() {
  warning "This task will enable production mode for ${SITE}\n"
  
  cd "${INSTALL_DIR}/${INSTANCE}"
  confirm "${SITE}"
  
  sudo su -c "
    apt update && apt upgrade -y &&      
    apt install --no-install-recommends -y \
        supervisor &&
    apt autoclean -y && apt autoremove -y"

  bench --site "${SITE}" set-config developer_mode False
  bench --site "${SITE}" set-maintenance-mode off  
  bench --site "${SITE}" add-to-hosts
  bench --site "${SITE}" enable-scheduler
  
  sudo su -c "
    yes | bench setup production $(whoami) &&
    service supervisor restart &&
    sed -i '6i chown="$(whoami)":"$(whoami)"' /etc/supervisor/supervisord.conf &&
    yes | bench setup production $(whoami) &&
    bench restart"
  STATUS_MSG+=$(success "Setup production Mode")
}

enable_dev() {
  cd "${INSTALL_DIR}/${INSTANCE}"
  bench --site "${SITE}" set-config developer_mode True
  STATUS_MSG+=$(success "Setup Development Mode")
}

install_frappe() {
  clear_screen
  print_header "Install Frappe Version ${FRAPPE_VERSION}"
  setup_repo && create_instance && create_site && \
  install_app

  case "${TYPE}" in
    dev)
      enable_dev 
      ;;
    aio)  ;;
    app)  ;;
    *)    ;;
  esac

  STATUS_MSG+=$(success "Install Frappe successful")
}
