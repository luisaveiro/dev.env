# shellcheck shell=bash
#
# DEV.env package configuration functions.

#######################################
# Add local development environment setup file to DEV.env.
#
# Arguments:
#   --setup_dir
#   --symlink
#   --name
#   setup file
#
# Returns:
#   1 setup file is not a shell script or
#   setup file does not exist or
#   user does not want to override existing setup file
#######################################
function env::local_configuration() {
  local arguments_list=("setup_dir" "symlink" "name")
  local file_name symlink setup_dir name setup_file=$*

  while [ $# -gt 0 ]; do
    if [[ $1 == *"--"* && $1 == *"="* ]]; then
      local argument="${1/--/}"
      IFS='=' read -ra parameter <<< "${argument}"

      if [[ "${arguments_list[*]}" =~ ${parameter[0]} ]]; then
        setup_file="${setup_file/--${argument}/}"
        declare "${parameter[0]}"="${parameter[1]}"
      fi
    fi

    shift
  done

  # Strip out whitespaces
  setup_file="${setup_file//[[:blank:]]/}"

  extension="$(file_extension "${setup_file}")"

  if [[ "${extension}" != "sh" ]]; then
    error "Development environment setup files must be a shell script file " \
      "and have the file extension $(ansi --bold --white .sh)."

    exit 1
  fi

  if [[ -z ${name} ]]; then
    file_name="$(file_name "${setup_file}")"
    name="${file_name}"
  fi

  extension="$(file_extension "${name}")"

  if [[ "${extension}" != "sh" ]]; then
    name="${name}.sh"
  fi

  if ! file_exists "${setup_file}"; then
    error "Unable to locate file $(ansi --bold --white "${file_name}")."
    info "Please check $(ansi --bold --white "${file_name}") exists and file" \
      "path ($(ansi --bold --white "$(dirname "${setup_file}")")) is correct."

    exit 1
  fi

  if file_exists "${setup_dir}/${name}"; then
    warning "$(ansi --bold --white "${name}")" \
      "already exists as a development environment setup file."

    if ! ask "Do you want to override the existing setup file?";
    then
      exit 1
    fi

    rm "${setup_dir}/${name}"

    info --newline=top --newline=bottom \
      "Replacing $(ansi --bold --white "${name}") setup file."
  fi

  if [[ ${symlink} == "true" ]]; then
    symlink --original="${setup_file}" --link="${setup_dir}/${name}"

    info "Created symlink $(ansi --bold --white "${name}") in" \
      "($(ansi --bold --white "${setup_dir}")) directory."
  else
    cp "${setup_file}" "${setup_dir}/${name}"

    # Make shell script executable
    cd "${setup_dir}" && chmod +x "${name}"

    info "Saved $(ansi --bold --white "${name}") in" \
      "($(ansi --bold --white "${setup_dir}")) directory."
  fi

  info "Use the following command to setup your" \
    "development environment $(ansi --bold --white env:setup "${name%.*}")"
}

#######################################
# Add remote development environment setup file to DEV.env.
#
# Arguments:
#   --directory
#   --setup_dir
#   --only
#   remote config
#
# Returns:
#   1 if remote repository not found
#######################################
function env::remote_configuration() {
  local arguments_list=("setup_dir" "only" "directory")
  local directory git setup_dir setup_files=() only clone_dir remote_config=$*

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

  if [[ -z ${directory} ]]; then
    clone_dir="${setup_dir}/${git}"
  else
    clone_dir="${setup_dir}/${directory}"
  fi

  if directory_exists "${clone_dir}"; then
    warning "Development environment setup files already exists in" \
      "$(ansi --bold --white "${clone_dir/${setup_dir}\//}")."

      if ! ask "Do you want to override the existing setup files?";
      then
        return
      fi

      rm -rf "${clone_dir:?}"

      info --newline=top --newline=bottom "Replacing" \
        "$(ansi --bold --white "${clone_dir/${setup_dir}\//}") setup files."
  fi

  if ! git::clone --quiet --git="${remote_config}" --dir="${clone_dir}"; then
    error "Remote repository not found. Could not read from remote repository."
    output "Please make sure you have the correct access rights" \
      "and the remote repository exists."

    exit 1
  fi

  if [[ -z ${only} ]]; then
    info "Saved $(ansi --bold --white "${git}")" \
      "in ($(ansi --bold --white "${clone_dir}")) directory."

    if [[ -z ${directory} ]]; then
      directory="${git}"
    fi

    info "Use the following command to setup your development environment" \
      "$(ansi --bold --white env:setup "${directory}/<setup-file>")"

    return
  fi

  IFS=',' read -ra setup_files <<< "${only}"

  for setup_file in "${setup_files[@]}"; do
    extension="$(file_extension "${setup_file}")"

    [[ "${extension}" != "sh" ]] &&
      name="${setup_file}.sh" || name="${setup_file}"

    if ! file_exists "${clone_dir}/${name}"; then
      warning --newline=bottom \
        "Unable to locate file $(ansi --bold --white "${name}") in" \
        "$(ansi --bold --white "${remote_config}")" \
        "$(ansi --bold --yellow "[SKIPPING]")"

      continue
    fi

    if file_exists "${setup_dir}/${name}"; then
      warning "$(ansi --bold --white "${name}")" \
        "already exists as a development environment setup file."

      if ! ask "Do you want to override the existing setup file?";
      then
        continue
      fi

      rm "${setup_dir}/${name}"

      info --newline=top --newline=bottom \
        "Replacing $(ansi --bold --white "${name}") setup file."
    fi

    mv "${clone_dir}/${name}" "${setup_dir}/${name}"

    info "Saved $(ansi --bold --white "${name}") in" \
      "($(ansi --bold --white "${setup_dir}")) directory."

    info --newline=bottom "Use the following command to setup your" \
      "development environment $(ansi --bold --white env:setup "${name%.*}")"
  done

  rm -rf "${clone_dir:?}"
}
