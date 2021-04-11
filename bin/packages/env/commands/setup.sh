# shellcheck shell=bash
#
# DEV.env package setup command.

#######################################
# Setup development environment.
#
# Arguments:
#   --setup_dir
#   setup_files
#
# Returns:
#   1 if setup file does not exists.
#######################################
function env::setup() {
  local arguments_list=("setup_dir")
  local setup_dir setup_files=$*

  while [ $# -gt 0 ]; do
    if [[ $1 == *"--"* && $1 == *"="* ]]; then
      local argument="${1/--/}"
      IFS='=' read -ra parameter <<< "${argument}"

      if [[ "${arguments_list[*]}" =~ ${parameter[0]} ]]; then
        setup_files="${setup_files/--${argument}/}"
        declare "${parameter[0]}"="${parameter[1]}"
      fi
    fi

    shift
  done

  IFS=' ' read -ra setup_files <<< "${setup_files}"

  if [[ ${#setup_files[@]} -eq 0 ]]; then
    error "Please provide a setup file name to configure your" \
      "development environment."
  fi

  for setup_file in "${setup_files[@]}"; do
    if [ "${setup_file: -3}" != ".sh" ]; then
      setup_file="${setup_file}.sh"
    fi

    if ! file_exists "${setup_dir}/${setup_file}"; then
      error --newline=bottom "Development environment setup file" \
        "$(ansi --bold --white "${setup_file}") does not exist."

      info "Use the following command to add ${setup_file} setup file:" \
        "$(ansi --bold --white env:config "path/${setup_file}")"

      exit 1
    fi

    # execute development environment setup shell script.
    cd ~ && bash "${setup_dir}/${setup_file}"
  done
}
