#!/usr/bin/env bash

set -eu

install_git() {
  clear_screen
  print_header "Install GIT Version ${GIT_VERSION}"

  if exists git; then
    local git_version=$(git --version 2>&1 | awk '{print $3}')
    STATUS_MSG+=$(success "GIT version ${git_version} already installed")
  else
    sudo su -c "
      cd /tmp
      curl -fsSL https://github.com/git/git/archive/refs/tags/v${GIT_VERSION}.zip -o git.zip &&
      unzip git.zip && 
      cd git-${GIT_VERSION} &&
      make clean && 
      make prefix=/usr/local all && 
      make prefix=/usr/local install &&
      rm git.zip && 
      rm -rf git-${GIT_VERSION}"
  
    STATUS_MSG+=$(success "Install GIT version ${GIT_VERSION} successful")
  fi

}

install_lazygit() {
  clear
  print_header "Install LazyGit"

  if exists lazygit; then
    STATUS_MSG+=$(success "LazyGIT already installed")
  else
    local version=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    sudo su -c "
      cd /tmp
      curl -Lo lazygit.tar.gz https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${version}_Linux_x86_64.tar.gz
      tar xf lazygit.tar.gz lazygit
	  sudo install lazygit /usr/local/bin
	  rm lazygit.tar.gz lazygit"
    STATUS_MSG+=$(success "Install LazyGIT successful")
  fi
}

install_ohmyposh() {
  clear
  print_header "Install oh-my-posh over zsh"
  
  sudo su -c "
    apt update &&
    apt upgrade -y && 
    apt install --no-install-recommends -y zsh &&
    apt autoclean -y"
  
  sudo su -c "curl https://ohmyposh.dev/install.sh | bash -s"
  local theme="catppuccin_frappe"
  mkdir -p $HOME/.oh-my-posh &&
    wget https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/${theme}.omp.json -O $HOME/.oh-my-posh/default.omp.json
  
  if ! grep -iq "oh-my-posh init zsh" ~/.zshrc; then  
    printf "\n%s" \
      "eval \"\$(oh-my-posh init zsh --config ~/.oh-my-posh/default.omp.json)\"" |
      tee -a $HOME/.zshrc >/dev/null
      chsh -s $(which zsh)
  fi
  STATUS_MSG+=$(success "Install oh-my-posh successful")
}

install_nvm() {
  clear_screen
  print_header "Install NVM"

  if exists nvm; then
    local node_version=$(node --version)
    STATUS_MSG+=$(success "NVM version ${node_version} already installed")
  else
    curl -fsSL https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
    
    if ! grep -iq "export NVM_DIR" ~/.zshrc; then
      printf "\n%s\n%s\n%s" \
        "export NVM_DIR=\"\$HOME/.nvm\"" \
        "[ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\"  # This loads nvm" \
        "[ -s \"\$NVM_DIR/bash_completion\" ] && \. \"\$NVM_DIR/bash_completion\"  # This loads nvm bash_completion" |
        tee -a ~/.zshrc ~/.bashrc >/dev/null
    fi
    STATUS_MSG+=$(success "Install NVM successful")

    #temporary export NVM_DIR to install node, npm and yarn
    export NVM_DIR="${HOME}/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

    nvm install v${NODE_VERSION} &&
    nvm install-latest-npm &&
    npm install -g yarn
    
    STATUS_MSG+=$(success "Install node, npm and yarn successful")
  fi

}

install_python() {
  clear_screen
  print_header "Install PYTHON Version ${PYTHON_VERSION}"
  
  if exists python; then
    python_version=$(python --version 2>&1 | awk '{print $2}')
    STATUS_MSG+=$(success "Python version ${python_version} already installed")
  else
    sudo su -c "
      apt update && apt upgrade -y && 
      apt install --no-install-recommends -y \
        libbz2-dev libncurses-dev libncursesw5-dev libgdbm-dev \
        liblzma-dev libsqlite3-dev libgdbm-compat-dev libreadline-dev &&
      apt autoclean -y && apt autoremove -y"

    sudo su -c "
      cd /tmp
      curl "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-${PYTHON_VERSION}.tar.xz" -o python.tar.xz
      mkdir -p /usr/src/python &&
      tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz &&
      rm -f python.tar.xz"

    cd /usr/src/python

    sudo su -c "./configure \
          --enable-optimizations \
          #--enable-option-checking=fatal \
          --enable-shared \
          #--without-ensurepip"

    sudo su -c "
      make clean &&
      make -j '$(nproc)' &&
      make install &&
      rm -rf /usr/src/python"

    find /usr/local -type d | grep -E "('test'|'tests'|'idle_test')" | xargs sudo rm -rf
    find /usr/local -type f | grep -E "('*.pyc'|'*.pyo'|'*.a')" | xargs sudo rm -f

    # create symlink
    cd /usr/local/bin
    
    sudo su -c "
      ln -s idle3 idle &&
      ln -s pydoc3 pydoc &&
      ln -s python3 python &&
      ln -s python3-config python-config &&
      ln -s pip3 pip"

    python -m pip install --upgrade pip
    python -m pip install --upgrade setuptools
    
    sudo python -m pip install poetry && \
      poetry config virtualenvs.in-project true

    STATUS_MSG+=$(success "Install PYTHON successful")
  fi

}
