# shellcheck shell=bash
#
# DEV.env Repos module add config command.

#######################################
# Add user's repositories YAML file to
# DEV.env.
#
# Globals:
#   APP_NAME
#
# Arguments:
#   User input
#
# Outputs:
#   Writes messages to stdout.
#
# Returns:
#   1 if user provides invalid
#   combination of arguments.
#######################################
function repos::command_add_config() {
  local arguments_list=("only-include" "rename")
  local config_file="$*"
  local extension
  local use_symlink=true
  local only_include
  local rename

  while [ $# -gt 0 ]; do
    if [[ $1 == *"--"* && $1 == *"="* ]]; then
      local argument="${1/--/}"
      IFS='=' read -ra parameter <<< "${argument}"

      if [[ "${arguments_list[*]}" =~ ${parameter[0]} ]]; then
        config_file="${config_file/--${argument}/}"
        declare "${parameter[0]//-/_}"="${parameter[1]}"
      fi
    elif [[ $1 == *"--no-symlink"* ]]; then
        config_file="${config_file/--no-symlink/}"
        use_symlink=false
    fi

    shift
  done

  # Strip out whitespaces
  config_file="${config_file//[[:blank:]]/}"

  if [ -z "${config_file}" ]; then
    console::info --margin-bottom \
      "$(ansi --bold --white "${APP_NAME}")" \
      "supports local and remote-based repositories configuration files."

    console::output "Please provide the full path of a local repositories" \
      "configuration file or the Git repository url of the remote-based" \
      "repositories configuration file."

    while [ -z "${config_file}" ]; do
      console::question --margin-top "What is the config file?"

      config_file="$(console::input)"

      if [ -z "${config_file}" ]; then
        console::error --margin-top \
          "You have not provided a valid repositories configuration file."
      fi
    done

    console::newline
  fi

  if [ -n "${only_include}" ]; then
    if ! filesystem::is_remote_file "${config_file}"; then
      console::error \
        "The $(ansi --bold --white "--only-include")" \
        "argument is only supported for remote configuration files."

      exit 1
    fi
  fi

  if [[ "${use_symlink}" == false ]]; then
    if filesystem::is_remote_file "${config_file}"; then
      console::error \
        "The $(ansi --bold --white "--no-symlink")" \
        "argument is only supported for local configuration files."

      exit 1
    fi
  fi

  if [ -n "${rename}" ]; then
    if [[ "${rename}" == *"."* ]]; then
      extension="$(filesystem::file_extension "${rename}")"

      if [[ "${extension}" != "yml" && "${extension}" != "yaml" ]]; then
        console::error \
          "You can only rename a configuration file with the YAML file" \
          "extension: $(ansi --bold --white ".yml") or" \
          "$(ansi --bold --white ".yaml")."

        exit 1
      fi
    fi

    # Set preferred .yaml extension
    rename="${rename%.*}.yaml"
  fi

  if ! filesystem::is_remote_file "${config_file}"; then
    configuration::add_local_configuration \
      --config_file="${config_file}" \
      --rename="${rename}" \
      --use_symlink="${use_symlink}"
  else
    configuration::add_remote_configuration \
      --git_repo_url="${config_file}" \
      --rename="${rename}" \
      --only_include="${only_include}"
  fi
}
