# shellcheck shell=bash
#
# Repos package help command.

#######################################
# Display help section
#######################################
function repos::help() {
  help::section "repos"

  local commands=(
    "repos:config"
    "repos:publish"
    "repos:setup"
    "repos:status"
  )

  local descriptions=(
    "Add repositories YAML file to DEV.env"
    "Publish repositories YAML file to a project directory"
    "Setup Git Repositories from repositories YAML file"
    "List all Git Repositories and setup status"
  )

  for index in "${!commands[@]}"
  do
    help::add_command \
      --command="${commands[index]}" \
      --description="${descriptions[index]}"
  done

  help::display_commands
}
