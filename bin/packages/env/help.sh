# shellcheck shell=bash
#
# DEV.env package help command.

#######################################
# Display help section
#######################################
function env::help() {
  help::section "env"

  local commands=(
    "env:config"
    "env:setup"
  )

  local descriptions=(
    "Add development environment setup file to DEV.env"
    "Setup your development environment "
  )

  for index in "${!commands[@]}"
  do
    help::add_command \
      --command="${commands[index]}" \
      --description="${descriptions[index]}"
  done

  help::display_commands
}
