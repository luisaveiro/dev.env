# shellcheck shell=bash
#
# Prototype package help command.

#######################################
# Display help section
#######################################
function prototype::help() {
  help::section "prototype"

  local commands=(
    "prototype:new"
    "prototype:samples"
  )

  local descriptions=(
    "Start a new prototype using Docker Compose samples"
    "List Docker Compose samples"
  )

  for index in "${!commands[@]}"
  do
    help::add_command \
      --command="${commands[index]}" \
      --description="${descriptions[index]}"
  done

  help::display_commands
}
