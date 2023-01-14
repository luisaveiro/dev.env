# shellcheck shell=bash
#
# DEV.env usage command.

#######################################
# Display the DEV.env usage options.
#
# Global:
#   APP_NAME
#   APP_TAGLINE
#   APP_COMMAND
#   GIT_REPOSITORY
#   MODULES_LIST
#
# Outputs:
#   Writes usage options to stdout.
#######################################
function command::usage() {
  local commands=(
    "about"
    "docs"
    "self-update"
    "version"
  )

  local descriptions=(
    "Shows a short information about ${APP_NAME}."
    "Open ${APP_NAME} documentation in the browser."
    "Update ${APP_NAME} to the latest version."
    "Display ${APP_NAME} installed version."
  )

  for index in "${!commands[@]}"; do
    help::add_command \
      --command="${commands[index]}" \
      --description="${descriptions[index]}"
  done

  help::title "${APP_NAME}"

  help::tagline "${APP_TAGLINE}"

  help::contribute \
    --package_name="${APP_NAME}" \
    --package_url="${GIT_REPOSITORY}"

  help::display_usage \
    --command_name="${APP_COMMAND}" \
    --has-arguments \
    --has-options

  help::display_commands --enable-title

  for module in "${MODULES_LIST[@]}"; do
    module::load "${module}"

    module_command="${module}::command_usage"

    if [[ $( type -t "${module_command}" ) == function ]]; then
      "${module_command}"
    fi
  done

  help::display_useful_tips \
    --command_name="${APP_COMMAND}"
}

#######################################
# Display helpful information for
# the usage command.
#
# Globals:
#   APP_COMMAND
#   GIT_REPOSITORY
#
# Outputs:
#   Writes helpful information to
#   stdout.
#######################################
function explain::usage() {
  local helpful_tips=(
    "The usage command lists all commands:"
    "${APP_COMMAND} usage"

    "Alternatively, you can use sonarqube without providing commands:"
    "${APP_COMMAND}"
  )

  explain::display_description \
    "Display a list of all available commands."
  explain::display_usage "usage"
  explain::display_helpful_tips "${helpful_tips[@]}"
  explain::display_more_information "${GIT_REPOSITORY}#usage-command"
}
