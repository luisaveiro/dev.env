# shellcheck shell=bash
#
# Repos package configuration functions.

#######################################
# Add local repositories YAML file to DEV.env.
#
# Arguments:
#   --template_dir
#   --name
#   YAML file
#
# Returns:
#   1 config file is not a YAML file or
#   config file does not exist or
#   user does not want to override existing config file
#######################################
function repos::local_configuration() {
  local arguments_list=("template_dir" "name")
  local file_name template_dir name config_file=$*

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

  extension="$(file_extension "${config_file}")"

  if [[ "${extension}" != "yml" ]]; then
    error "Repositories configuration files must be YAML files" \
      "and have the file extension $(ansi --bold --white .yml)."

    exit 1
  fi

  if [[ -z ${name} ]]; then
    file_name="$(file_name "${config_file}")"
    name="${file_name}"
  fi

  extension="$(file_extension "${name}")"

  if [[ "${extension}" != "yml" ]]; then
    name="${name}.yml"
  fi

  if [[ $name == "repositories-template.yml" ]]; then
    error "$(ansi --bold --white "${name}") is a reserved configuration" \
      "template! Please select a different configuration name."

    exit 1
  fi

  if ! file_exists "${config_file}"; then
    error "Unable to locate file $(ansi --bold --white "${file_name}")."
    info "Please check $(ansi --bold --white "${file_name}") exists and file" \
      "path ($(ansi --bold --white "$(dirname "${config_file}")")) is correct."

    exit 1
  fi

  if file_exists "${template_dir}/${name}"; then
    warning "$(ansi --bold --white "${name}")" \
      "already exists as a YAML repository configuration file."

    if ! ask "Do you want to override the existing YAML repository configuration file?";
    then
      exit 1
    fi

    rm "${template_dir}/${name}"

    info --newline=top --newline=bottom "Replacing" \
      "$(ansi --bold --white "${name}") YAML repository configuration file."
  fi

  cp "${config_file}" "${template_dir}/${name}"

  info "Saved $(ansi --bold --white "${name}") in" \
    "($(ansi --bold --white "${template_dir}")) directory."

  info "Use the following command to publish your YAML repository" \
    "configuration file $(ansi --bold --white repos:publish "${name%.*}")"
}

#######################################
# Add remote repositories YAML file to DEV.env.
#
# Arguments:
#   --template_dir
#   --only
#   remote repositories
#
# Returns:
#   1 if remote repository not found
#######################################
function repos::remote_configuration() {
  local arguments_list=("template_dir" "only")
  local git template_dir config_files=() only clone_dir remote_config=$*

  while [ $# -gt 0 ]; do
    if [[ $1 == *"--"* && $1 == *"="* ]]; then
      local argument="${1/--/}"
      IFS='=' read -ra parameter <<< "${argument}"

      if [[ "${arguments_list[*]}" =~ ${parameter[0]} ]]; then
        remote_config="${remote_config/--${argument}/}"
        declare "${parameter[0]}"="${parameter[1]}"
      fi
    fi

    shift
  done

  # Strip out whitespaces
  remote_config="${remote_config//[[:blank:]]/}"

  if git::is_gist "${remote_config}"; then
    git="$(git::gist_hash "${remote_config}")"
  else
    git="$(git::repository "${remote_config}")"
  fi

  clone_dir="${template_dir}/${git}"

  if ! git::clone --quiet --git="${remote_config}" --dir="${clone_dir}"; then
    error "Remote repository not found. Could not read from remote repository."
    output "Please make sure you have the correct access rights" \
      "and the remote repository exists."

    exit 1
  fi

  if [[ -z ${only} ]]; then
    files=("${clone_dir}"/*)

    for file in "${files[@]}"; do
      file_name="$(file_name "${file}")"
      extension="$(file_extension "${file_name}")"

      if [[ "${extension}" != "yml" ]]; then
        continue
      fi

      if [[ "${file_name}" == "repositories-template.yml" ]]; then
        warning --newline=bottom "$(ansi --bold --white "${file_name}")" \
          "is a reserved configuration template! Please select a different" \
          "configuration name $(ansi --bold --yellow "[SKIPPING]")"

        continue
      fi

      if file_exists "${template_dir}/${file_name}"; then
        warning "$(ansi --bold --white "${file_name}")" \
          "already exists as a YAML repository configuration file."

        if ! ask "Do you want to override the existing YAML repository configuration file?";
        then
          continue
        fi

        rm "${template_dir}/${file_name}"

        info --newline=top --newline=bottom \
          "Replacing $(ansi --bold --white "${file_name}")" \
          "YAML repository configuration file."
      fi

      mv "${file}" "${template_dir}/${file_name}"

      info "Saved $(ansi --bold --white "${file_name}") in" \
        "($(ansi --bold --white "${template_dir}")) directory."

      info "Use the following command to publish your YAML repository" \
        "configuration file" \
        "$(ansi --bold --white repos:publish "${file_name%.*}")"
    done
  else
    IFS=',' read -ra config_files <<< "${only}"

    for config_file in "${config_files[@]}"; do
      extension="$(file_extension "${config_file}")"

      [[ "${extension}" != "yml" ]] &&
        name="${config_file}.yml" || name="${config_file}"

      if ! file_exists "${clone_dir}/${name}"; then
        warning --newline=bottom \
          "Unable to locate file $(ansi --bold --white "${name}") in" \
          "$(ansi --bold --white "${remote_config}")" \
          "$(ansi --bold --yellow "[SKIPPING]")"

        continue
      fi

      if [[ "${name}" == "repositories-template.yml" ]]; then
        warning --newline=bottom "$(ansi --bold --white "${name}")" \
          "is a reserved configuration template! Please select a different" \
          "configuration name $(ansi --bold --yellow "[SKIPPING]")"

        continue
      fi

      if file_exists "${template_dir}/${name}"; then
        warning "$(ansi --bold --white "${name}")" \
          "already exists as a YAML repository configuration file."

        if ! ask "Do you want to override the existing YAML repository configuration file?";
        then
          continue
        fi

        rm "${template_dir}/${name}"

        info --newline=top --newline=bottom \
          "Replacing $(ansi --bold --white "${name}")" \
          "YAML repository configuration file."
      fi

      mv "${clone_dir}/${name}" "${template_dir}/${name}"

      info "Saved $(ansi --bold --white "${name}") in" \
        "($(ansi --bold --white "${template_dir}")) directory."

      info "Use the following command to publish your YAML repository" \
        "configuration file" \
        "$(ansi --bold --white repos:publish "${file_name%.*}")"
    done
  fi

  rm -rf "${clone_dir:?}"
}
