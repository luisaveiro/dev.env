# shellcheck shell=bash
#
# DEV.env Repos module publish command.

#######################################
# Publish repositories template file
# to a project directory.
#
# Global:
#   APP_COMMAND
#   REPOS_TEMPLATE_YAML
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
  local template_name="${REPOS_TEMPLATE_YAML}"
  local use_symlink=true
  local user_template="$*"

  while [ $# -gt 0 ]; do
    if [[ $1 == *"--no-symlink"* ]]; then
        user_template="${user_template/--no-symlink/}"
        use_symlink=false
    fi

    shift
  done

  # Strip out whitespaces
  user_template="${user_template//[[:blank:]]/}"

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
    # Set preferred .yaml extension
    template_name="${user_template%.*}.yaml"
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

  if [[
    "${use_symlink}" == false || "${template_name}" == "${REPOS_TEMPLATE_YAML}"
  ]]; then
    cp "${TEMPLATE_DIR}/${template_name}" "$(pwd)/${REPOS_YAML}"
  else
    filesystem::create_symlink \
      --original="${TEMPLATE_DIR}/${template_name}" \
      --link="$(pwd)/${REPOS_YAML}"
  fi

  console::info \
    "Published $(ansi --bold --white "${REPOS_YAML}") using" \
    "$(ansi --bold --white "${template_name}") repository template file."
}
