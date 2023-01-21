# shellcheck shell=bash
#
# DEV.env Repos module list command.

#######################################
# List available templates for
# repositories
#
# Globals:
#   APP_NAME
#   TEMPLATE_DIR
#
# Outputs:
#   Writes list of repositories files
#   to stdout.
#######################################
function repos::command_list() {
  local templates=()

  for template in "${TEMPLATE_DIR}"/*; do
    if [[ -d "${template}" ]]; then
      continue
    fi

    template="$( filesystem::file_name "${template}" )"
    templates+=("${template//.yaml/}")
  done

  if [ "${#templates[@]}" -eq 1 ]; then
    console::info --margin-bottom \
      "$(ansi --bold --white "${APP_NAME}") has" \
      "$(ansi --bold --white "${#templates[@]}") repositories template file."

    console::output "The repositories template file that is available:"
  else
    console::info --margin-bottom \
      "$(ansi --bold --white "${APP_NAME}") has" \
      "$(ansi --bold --white "${#templates[@]}") repositories template files."

    console::output "The repositories template files that are available:"
  fi

  printf -- '- %s\n' "${templates[@]}"
}
