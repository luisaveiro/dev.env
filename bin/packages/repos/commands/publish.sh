# shellcheck shell=bash
#
# Repos package publish command.

#######################################
# Publish repositories YML file to a project directory.
#
# Arguments:
#   --template_dir
#   user_template
#
# Returns:
#   1 if repositories file already exists in directory
#   or repositories template YAML file does not exist.
#######################################
function repos::publish() {
  local arguments_list=("template_dir")
  local template_dir repositories_template repositories_template_name
  local user_template=$*

  while [ $# -gt 0 ]; do
    if [[ $1 == *"--"* && $1 == *"="* ]]; then
      local argument="${1/--/}"
      IFS='=' read -ra parameter <<< "${argument}"

      if [[ "${arguments_list[*]}" =~ ${parameter[0]} ]]; then
        user_template="${user_template/--${argument}/}"
        declare "${parameter[0]}"="${parameter[1]}"
      fi
    fi

    shift
  done

  # Strip out whitespaces
  user_template="${user_template//[[:blank:]]/}"

  [[ -z $user_template ]] &&
    repositories_template_name="repositories-template" ||
    repositories_template_name="${user_template}"

  repositories_template="${template_dir}/${repositories_template_name}.yml"

  if ! file_exists "${repositories_template}"; then
    error "Repositories template" \
      "$(ansi --bold --white "${repositories_template_name}") does not exist."

    exit 1
  fi

  if file_exists "$(pwd)/repositories.yml"; then
    warning "Unable to publish repository template because directory already" \
      "has $(ansi --bold --white "repositories.yml")."

    exit 1
  fi

  cp "${repositories_template}" "$(pwd)/repositories.yml"

  info "Published $(ansi --bold --white "repositories.yml") using" \
    "$(ansi --bold --white "${repositories_template_name}.yml") template."
}
