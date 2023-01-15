# shellcheck shell=bash
#
# DEV.env Repos module publish command.

#######################################
# Publish repositories template file
# to a project directory.
#
# Global:
#   APP_COMMAND
#   REPOS_YAML
#   TEMPLATE_DIR
#
# Arguments:
#   User input
#
# Outputs:
#   Writes usage options to stdout.
#######################################
function repos::command_publish() {
  local template_name="repositories-template.yml"
  local user_template="${1}"

  if filesystem::does_file_exists "$(pwd)/${REPOS_YAML}"; then
    console::warning --margin-bottom \
      "$(ansi --bold --white "${REPOS_YAML}") exists."

    console::output \
      "Unable to publish repository template file because this project" \
      "($(ansi --bold --white "$( basename "$(pwd)" )")) already has a" \
      "$(ansi --bold --white "${REPOS_YAML}") file."

      exit 1
  fi

  if [ -n "${user_template}" ]; then
    template_name="${user_template//.yml/}.yml"
  fi

  if ! filesystem::does_file_exists "${TEMPLATE_DIR}/${template_name}"; then
    console::error --margin-bottom \
      "The $(ansi --bold --white "${template_name}")" \
      "repository template file does not exist."

    console::output \
      "To view a list of available repository template files. Use the" \
      "following command: $(ansi --bold --white "${APP_COMMAND} repos:list")."

    exit 1
  fi

  cp "${TEMPLATE_DIR}/${template_name}" "$(pwd)/${REPOS_YAML}"

  console::info --margin-bottom \
    "Published $(ansi --bold --white "${REPOS_YAML}") using" \
    "$(ansi --bold --white "${template_name}") repository template file."
}
