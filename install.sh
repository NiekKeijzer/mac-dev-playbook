#!/usr/bin/env bash

project_dir="$HOME/.setup/mac-dev"
venv_dir="$project_dir/.env"

clone_repo() 
{
  if [ ! -d "$project_dir" ]; then 
    git clone https://github.com/NiekKeijzer/mac-dev-playbook.git "$project_dir" 
  fi

  cd "$project_dir"
  git -C "$project_dir" pull
}

maybe_create_venv() 
{
  if [ ! -d "$venv_dir" ]; then 
    python3 -m venv "$venv_dir"
    eval "$venv_dir/bin/python3 -m pip install -r $project_dir/requirements.txt"
  fi
}

install_dependencies() 
{
  if ! type xcode-select >&- && xpath=$( xcode-select --print-path ) &&
   test -d "${xpath}" && test -x "${xpath}" ; then
   xcode-select --install
  fi

  eval "$venv_dir/bin/ansible-galaxy install -r requirements.yml"
}

main() 
{
  # Prepare the environment
  clone_repo
  maybe_create_venv
  install_dependencies

  # Run Ansible
  exec "$venv_dir/bin/ansible-playbook main.yml -i inventory --ask-become-pass"
}

main