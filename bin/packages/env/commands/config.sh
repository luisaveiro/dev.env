# shellcheck shell=bash
#
# DEV.env package config command.

#######################################
# Add development environment setup file to DEV.env.
#
# Globals:
#   User
#
# Arguments:
#   --setup_dir
#   --name
#   setup_file
#
# Returns:
#   1 if remote setup file missing name or
#   user does not want to override existing setup file or
#   setup file does not exist.
#######################################
function env::config() {
  local arguments_list=("setup_dir" "name")
  local setup_dir name setup_file=$*

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

  if [[ -z ${name} ]] && is_file_remote "${setup_file}"; then
    error --newline=bottom "You need to include the" \
      "$(ansi --bold --white --name) option for remote based" \
      "development environment setup files."

    info --newline=bottom "Update your command input with the follows:"

    output "$(ansi --bold --white dev env:config "${setup_file}")" \
      "$(ansi --bold --white --inverse --name="${USER:-personal}")"

    exit 1;
  elif ! is_file_remote "${setup_file}"; then
    local file_name
    file_name="$(basename -- "${setup_file}")"

    if [ "${file_name: -3}" != ".sh" ]; then
      error "Development environment setup file must be a shell script file."

      exit 1
    fi

    if [[ -z ${name} ]]; then
      name="${file_name}"
    fi
  fi

  if [ "${name: -3}" != ".sh" ]; then
    name="${name}.sh"
  fi

  # check if file already exists.
  if file_exists "${setup_dir}/${name}"; then
    warning "$(ansi --bold --white "${name}")" \
      "already exists as a development environment setup file."

    if ! ask "Do you want to override the existing development environment setup file?";
    then
      exit 1
    fi
  fi

  if is_file_remote "${setup_file}"; then
    local gist_hash gist_dir
    gist_hash="$(git::gist_hash "${setup_file}")"
    gist_dir="${setup_dir}/${gist_hash}"

    if ! git::clone --quiet --git="${setup_file}" --dir="${gist_dir}"; then
      error "Gist hash not found. Could not read from remote repository."
      output "Please make sure you have the correct access rights" \
        "and the gist hash exists."
    fi

    mv "${gist_dir}/${name}" "${setup_dir}/${name}"
    rm -rf "${gist_dir:?}"
  else
    if ! file_exists "${setup_file}"; then
      error "Unable to locate file" \
        "$(ansi --bold --white "$(file_name "${setup_file}")")."
      info "Please check" \
        "$(ansi --bold --white "$(file_name "${setup_file}")")" \
        "exists and file path" \
        "($(ansi --bold --white "$( dirname "${setup_file}")")) is correct."

      exit 1
    fi

    cp "${setup_file}" "${setup_dir}/${name}"
  fi

  # Make shell script executable
  cd "${setup_dir}" && chmod +x "${name}"

  info --newline=top "Saved $(ansi --bold --white "${name}") in" \
    "($(ansi --bold --white "${setup_dir}")) directory."

  exit 0;
}
