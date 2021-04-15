# shellcheck shell=bash
#
# Repos package config command.

#######################################
# Add repositories YAML file to DEV.env.
#
# Arguments:
#   --template_dir
#   --only
#   --name
#   config file
#
# Returns:
#   1 if remote config file missing name or
#   config file is not a valid YAML file or
#   config name is a reserved config name or
#   user does not want to override existing config file or
#   config file does not exist.
#######################################
function repos::config() {
  local arguments_list=("template_dir" "only" "name")
  local template_dir only name config_file=$*

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

  if ! is_file_remote "${config_file}"; then
    repos::local_configuration \
      --template_dir="${template_dir}" \
      --name="${name}" \
      "${config_file}"
  else
    repos::remote_configuration \
      --template_dir="${template_dir}" \
      --only="${only}" \
      "${config_file}"
  fi
}
