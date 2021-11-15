# shellcheck shell=bash
#
# DEV.env package list command.

#######################################
# List development environment files.
#
# Arguments:
#   --setup_dir
#
# Returns:
#   1 if setup file does not exists.
#######################################
function env::list() {
  local arguments_list=("setup_dir")
  local setup_dir setup_files=()

  while [ $# -gt 0 ]; do
    if [[ $1 == *"--"* && $1 == *"="* ]]; then
      local argument="${1/--/}"
      IFS='=' read -ra parameter <<< "${argument}"

      if [[ "${arguments_list[*]}" =~ ${parameter[0]} ]]; then
        declare "${parameter[0]}"="${parameter[1]}"
      fi
    fi

    shift
  done

  setup_dir="${setup_dir}/*"

  for setup_file in ${setup_dir}
  do
    if [[ ! -f "${setup_file}" ]]; then
      break
    fi

    file_name="$(file_name "${setup_file}")"
    extension="$(file_extension "${file_name}")"

    if [[ "${extension}" != "sh" ]]; then
      break
    fi

    [[ -L "${setup_file}" ]] &&
      symlink="$(readlink "${setup_file}")" || symlink="N/A"

    setup_files+=(
      "${file_name%.*}"
      "${symlink}"
      "$(date -r "${setup_file}")"
    )
  done

  total_files="$((${#setup_files[@]}/3))"

  if [[ ${total_files} -lt 0 ]]; then
    # shellcheck disable=SC2059
    printf "$(ansi --white --bold %-18s) $(ansi --green --bold %3d) \n" \
      "- Total Setup Files" "${total_files}"

    newline

    table::row_numbers true
    table::header_style "--green"
    table::header "Setup File" "Symbolic Link" "Date Modified"
    table::records "${setup_files[@]}"
    table::display

    info --newline=top "Use the following command to setup your" \
      "development environment $(ansi --bold --white env:setup "<setup-file>")"
  else
    warning --newline=bottom "There are no development environment setup" \
      "files configured."

    info "Use the following command to add a setup file:" \
      "$(ansi --bold --white env:config "<path/setup-file>")"
  fi
}
