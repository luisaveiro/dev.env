# shellcheck shell=bash
#
# DEV.env Repos module usage command.

#######################################
# Display the Repos module usage
# command options.
#
# Global:
#   APP_NAME
#   MODULE_NAME
#
# Outputs:
#   Writes usage options to stdout.
#######################################
function repos::command_usage() {
  local commands=(
    "add-config"
    "list"
    "publish"
    "setup"
    "status"
  )

  local descriptions=(
    "Add repositories YAML file to ${APP_NAME}."
    "List available repositories template files."
    "Publish repositories YAML file to a project directory."
    "Setup Git repositories from repositories YAML file."
    "List all Git repositories and setup status."
  )

  help::add_section "${MODULE_NAME}"

  for index in "${!commands[@]}"; do
    help::add_command \
      --command="${MODULE_NAME}:${commands[index]}" \
      --description="${descriptions[index]}"
  done

  help::display_commands
}
