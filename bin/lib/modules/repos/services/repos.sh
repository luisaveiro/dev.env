# shellcheck shell=bash
#
# Load DEV.env Repos module repos service functions.

#######################################
# Add a local repositories YAML file
# to DEV.env.
#
# Arguments:
#   --config_file
#   --rename
#   --use_symlink
#
# Outputs:
#   Writes messages to stdout.
#
# Returns:
#   1 if config file is invalid for
#     certain conditions.
#######################################
function repos::add_local_configuration() {
  local arguments_list=("config_file" "rename" "use_symlink")
  local config_file
  local file_extension
  local rename
  local use_symlink=true

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

  file_extension="$(filesystem::file_extension "${config_file}")"

  if [[ "${file_extension}" != "yml" && "${file_extension}" != "yaml" ]]; then
    console::error \
      "Repositories configuration files must be a YAML file and have the YAML" \
      "file extension: $(ansi --bold --white .yml) or" \
      "$(ansi --bold --white .yaml)."

    exit 1
  fi

  repo_configuration::copy_config_file \
    --config_file="${config_file}" \
    --rename="${rename}" \
    --use_symlink="${use_symlink}"
}

#######################################
# Add remote repositories YAML file(s)
# to DEV.env.
#
# Globals:
#   APP_COMMAND
#   TEMPLATE_DIR
#
# Arguments:
#   --git_repo_url
#   --only_include
#   --rename
#
# Outputs:
#   Writes messages to stdout.
#
# Returns:
#   1 if the combination of arguments
#     is invalid.
#######################################
function repos::add_remote_configuration() {
  local arguments_list=("git_repo_url" "only_include" "rename")
  local clone_dir
  local git_repo_url
  local included_list=()
  local only_include
  local rename

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

  IFS=',' read -ra only_includes <<< "${only_include}"

  for include_file in "${only_includes[@]}"; do
    # Set preferred .yaml extension
    include_file="${include_file%.*}.yaml"

    included_list+=("${include_file}")
  done

  unset only_includes

  if [[ -n "${rename}" && "${#included_list[@]}" -ne 1 ]]; then
    console::error \
      "The $(ansi --bold --white "--only-include")" \
      "argument must only have one configuration file when using the" \
      "$(ansi --bold --white "--rename") argument."

    console::output --margin-top \
      "Try the $(ansi --bold --white "repos:add-config") command as follow:" \
      "$(ansi --bold --white "${APP_COMMAND} repos:add-config ${git_repo_url}")" \
      "$(ansi --bold --white "--rename=${rename%.*}")" \
      "$(ansi --bold --white --italic "--only-include=${included_list[0]%.*}")"

    exit 1
  fi

  # Ensure Git Remote URL ends with .git
  git_repo_url="${git_repo_url//.git/}.git"

  if ! git::is_valid_git_url "${git_repo_url}"; then
    console::error --margin-bottom \
      "$(ansi --bold --white "${git_repo_url}") is not a valid Git Remote URL."

    console::output --margin-bottom \
      "There are two types of Git Remote URL addresses:"

    console::output "- An HTTPS URL, e.g." \
      "$(ansi --bold --white "https://github.com/user/repo.git")"

    console::output "- An SSH URL, e.g." \
      "$(ansi --bold --white "git@github.com:user/repo.git")"

    exit 1
  fi

  clone_dir="${TEMPLATE_DIR}/temp"

  if filesystem::does_directory_exists "${clone_dir}"; then
    rm -rf "${clone_dir:?}"
  fi

  if ! git::clone --quiet --repo="${git_repo_url}" --dir="${clone_dir}"; then
    console::error --margin-bottom \
      "Remote repository ($(ansi --bold --white "${git_repo_url}"))" \
      "not found. Could not read from remote repository."

    console::output \
      "Please make sure you have the correct access rights and the remote" \
      "repository exists."

    exit 1
  fi

  files=("${clone_dir}"/*)

  for config_file in "${files[@]}"; do
    file_extension="$(filesystem::file_extension "${config_file}")"

    if [[ "${file_extension}" != "yml" && "${file_extension}" != "yaml" ]]; then
      continue
    fi

    if [[ -n "${only_include}" ]]; then
      file_name="$(filesystem::file_name "${config_file}")"
      file_name="${file_name%.*}.yaml"

      if [[ "${included_list[*]}" =~ ${file_name} ]]; then
        repo_configuration::copy_config_file \
          --config_file="${config_file}" \
          --rename="${rename}" \
          --use_symlink=false
      fi
    else
      repo_configuration::copy_config_file \
        --config_file="${config_file}" \
        --use_symlink=false
    fi
  done

  rm -rf "${clone_dir:?}"
}
