# shellcheck shell=bash
#
# Repos package config command.

#######################################
# Add repositories YML file to DEV.env.
#
# Globals:
#   User
#
# Arguments:
#   --template_dir
#   --name
#   config_path
#
# Returns:
#   1 if remote config file missing name or
#   config file is not a valid YAML file or
#   config name is a reserved config name or
#   user does not want to override existing config file or
#   config file does not exist.
#######################################
function repos::config() {
  local arguments_list=("template_dir" "name")
  local template_dir name config_file=$*

  while [ $# -gt 0 ]; do
    if [[ $1 == *"--"* && $1 == *"="* ]]; then
      local argument="${1/--/}"
      IFS='=' read -ra parameter <<< "${argument}"

      if [[ "${arguments_list[*]}" =~ ${parameter[0]} ]]; then
        config_file="${config_file/--${argument}/}"
        declare "${parameter[0]}"="${parameter[1]}"
      fi
    fi

    shift
  done

  # Strip out whitespaces
  config_file="${config_file//[[:blank:]]/}"

  if [[ -z ${name} ]] && is_file_remote "${config_file}"; then
    error --newline=bottom "You need to include the" \
      "$(ansi --bold --white --name) option for remote based repositories" \
      "configuration files."

    info --newline=bottom "Update your command input with the follows:"

    output "$(ansi --bold --white dev repos:config "${config_file}")" \
      "$(ansi --bold --white --inverse --name="${USER:-personal}")"

    exit 1;
  elif ! is_file_remote "${config_file}"; then
    local file_name
    file_name="$(basename -- "${config_file}")"

    if [ "${file_name: -4}" != ".yml" ]; then
      error "Repositories configuration file must be a YAML file."

      exit 1
    fi

    if [[ -z ${name} ]]; then
      name="${file_name}"
    fi
  fi

  if [ "${name: -4}" != ".yml" ]; then
    name="${name}.yml"
  fi

  if [[ $name == "repositories-template.yml" ]]; then
    error "$(ansi --bold --white "${name}")" \
      "is a reserved configuration template!" \
      "Please select a different configuration name."

    exit 1
  fi

  # check if file already exists.
  if file_exists "${template_dir}/${name}"; then
    warning "$(ansi --bold --white "${name}")" \
      "already exists as a repositories configuration file."

    if ! ask "Do you want to override the existing repositories configuration file?";
    then
      exit 1
    fi
  fi

  if is_file_remote "${config_file}"; then
    local gist_hash gist_dir
    gist_hash="$(git::gist_hash "${config_file}")"
    gist_dir="${template_dir}/${gist_hash}"

    if ! git::clone --quiet --git="${config_file}" --dir="${gist_dir}"; then
      error "Gist hash not found. Could not read from remote repository."
      output "Please make sure you have the correct access rights" \
        "and the gist hash exists."
    fi

    mv "${gist_dir}/${name}" "${template_dir}/${name}"
    rm -rf "${gist_dir:?}"
  else
    if ! file_exists "${config_file}"; then
      error "Unable to locate file" \
        "$(ansi --bold --white "$(file_name "${config_file}")")."
      info "Please check" \
        "$(ansi --bold --white "$(file_name "${config_file}")")" \
        "exists and file path" \
        "($(ansi --bold --white "$( dirname "${config_file}")")) is correct."

      exit 1
    fi

    cp "${config_file}" "${template_dir}/${name}"
  fi

  info --newline=top "Saved $(ansi --bold --white "${name}") in" \
    "($(ansi --bold --white "${template_dir}")) directory."
}
