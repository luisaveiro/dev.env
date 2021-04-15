# shellcheck shell=bash
#
# DEV.env package config command.

#######################################
# Add development environment setup file to DEV.env.
#
# Arguments:
#   --directory
#   --only
#   --setup_dir
#   --name
#   setup file
#
# Returns:
#   1 if remote setup file missing name or
#   user does not want to override existing setup file or
#   setup file does not exist.
#######################################
function env::config() {
  local arguments_list=("setup_dir" "directory" "only" "name")
  local directory symlink=true setup_dir only name setup_file=$*

  while [ $# -gt 0 ]; do
    if [[ $1 == *"--"* && $1 == *"="* ]]; then
      local argument="${1/--/}"
      IFS='=' read -ra parameter <<< "${argument}"

      if [[ "${arguments_list[*]}" =~ ${parameter[0]} ]]; then
        setup_file="${setup_file/--${argument}/}"
        declare "${parameter[0]}"="${parameter[1]}"
      fi
    elif [[ $1 == *"--no-symlink"* ]]; then
      setup_file="${setup_file/--no-symlink/}"
      symlink=false
    fi

    shift
  done

  # Strip out whitespaces
  setup_file="${setup_file//[[:blank:]]/}"

  if ! is_file_remote "${setup_file}"; then
    env::local_configuration \
      --setup_dir="${setup_dir}" \
      --symlink="${symlink}" \
      --name="${name}" \
      "${setup_file}"
  else
    env::remote_configuration \
      --setup_dir="${setup_dir}" \
      --directory="${directory}" \
      --only="${only}" \
      "${setup_file}"
  fi
}
