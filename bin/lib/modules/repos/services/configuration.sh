# shellcheck shell=bash
#
# Load DEV.env Repos module configuration service functions.

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
function configuration::add_local_configuration() {
  local arguments_list=("config_file" "rename" "use_symlink")
  local config_file
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

  unset arguments_list

  if ! filesystem::is_yaml_file "${config_file}"; then
    console::error \
      "Repositories configuration files must be a YAML file and have the YAML" \
      "file extension: $(ansi --bold --white .yml) or" \
      "$(ansi --bold --white .yaml)."

    exit 1
  fi

  configuration::copy_config_file \
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
#   --path
#   --rename
#
# Outputs:
#   Writes messages to stdout.
#
# Returns:
#   1 if the combination of arguments
#     is invalid.
#######################################
function configuration::add_remote_configuration() {
  local arguments_list=("git_repo_url" "only_include" "path" "rename")
  local clone_dir
  local git_repo_url
  local included_list=()
  local only_include
  local path
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

  unset arguments_list

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

  configuration::find_config_files \
    --dir="${clone_dir}/${path}" \
    --only_include="${only_include}" \
    --rename="${rename}"

  rm -rf "${clone_dir:?}"
}


#######################################
# Add remote repositories YAML file(s)
# to DEV.env.
#
# Globals:
#   REPOS_TEMPLATE_YAML
#   TEMPLATE_DIR
#
# Arguments:
#   --config_file
#   --rename
#   --use_symlink
#
# Outputs:
#   Writes messages to stdout.
#
# Returns
#   if config file is invalid for
#   certain conditions.
#######################################
function configuration::copy_config_file() {
  local arguments_list=("config_file" "rename" "use_symlink")
  local config_file
  local file_name
  local file_path
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

  unset arguments_list

  if ! filesystem::is_yaml_file "${config_file}"; then
    return
  fi

  file_path="$(filesystem::file_path "${config_file}")"
  file_name="$(filesystem::file_name "${config_file}")"

  if ! filesystem::does_file_exists "${config_file}"; then
    console::error --margin-bottom \
      "Unable to locate file $(ansi --bold --white "${file_name}")."

    console::output \
      "Please check $(ansi --bold --white "${file_name}") exists and the file" \
      "path ($(ansi --bold --white "${file_path}")) is correct."

    return
  fi

  # Set preferred .yaml extension
  file_name="${file_name%.*}.yaml"

  if [ -n "${rename}" ]; then
    file_name="${rename}"
  fi

  if [[ "${file_name}" == "${REPOS_TEMPLATE_YAML}" ]]; then
    console::warning \
      "$(ansi --bold --white "${REPOS_TEMPLATE_YAML}") is a reserved" \
      "configuration template! Please use a different configuration name." \
      "$(ansi --bold --yellow "[SKIPPING]")"

    return
  fi

  if filesystem::does_file_exists "${TEMPLATE_DIR}/${file_name}"; then
    console::warning --margin-bottom \
      "$(ansi --bold --white "${file_name}") already exists as a YAML" \
      "repository configuration file."

    question="Do you want to override the existing YAML repository "
    question+="configuration file, (${file_name})?"

    if ! console::ask --message="${question}" --default="N"; then
      console::notice --margin-top --margin-bottom \
        "Skipping $(ansi --bold --white "${file_name}") YAML repository" \
        "configuration file!"

      return
    fi

    rm "${TEMPLATE_DIR}/${file_name}"

    console::notice --margin-top --margin-bottom \
      "Replacing $(ansi --bold --white "${file_name}") YAML repository" \
      "configuration file!"
  fi

  if [[ "${use_symlink}" == false ]]; then
    cp "${config_file}" "${TEMPLATE_DIR}/${file_name}"
  else
    symlink::create \
      --original="${config_file}" \
      --link="${TEMPLATE_DIR}/${file_name}"
  fi

  if [ -z "${rename}" ]; then
    console::info --margin-bottom \
      "Saved $(ansi --bold --white "${file_name}") in" \
      "($(ansi --bold --white "${TEMPLATE_DIR}")) directory."
  else
    orginal_file_name="$(filesystem::file_name "${config_file}")"

    console::info --margin-bottom \
      "Saved ${orginal_file_name} as $(ansi --bold --white "${file_name}") in" \
      "($(ansi --bold --white "${TEMPLATE_DIR}")) directory."
  fi

  console::output --margin-bottom \
    "Use the following command to publish your YAML repository configuration" \
    "file: $(ansi --bold --white repos:publish "${file_name%.*}")."
}

#######################################
# Find repositories YAML file(s) in a
# directoy.
#
# Arguments:
#   --dir
#   --only_include
#   --rename
#######################################
function configuration::find_config_files() {
  local arguments_list=("dir" "only_include" "rename")
  local dir
  local files=()
  local included_list=()
  local only_include
  local rename
  local yaml
  local yaml_prefix="yaml_"

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

  unset arguments_list

  IFS=',' read -ra only_includes <<< "${only_include}"

  for include_file in "${only_includes[@]}"; do
    included_list+=("${include_file}")
  done

  unset only_includes

  files=("${dir/\//}"/*)

  for file in "${files[@]}"; do
    if filesystem::does_directory_exists "${file}"; then
      configuration::find_config_files \
        --dir="${file}" \
        --only_include="${only_include}" \
        --rename="${rename}"

      continue
    fi

    if ! filesystem::is_yaml_file "${file}"; then
      continue
    fi

    # Parse the repositories.yaml file.
    yaml="$(yaml::parse_yaml \
      --file="${file}" \
      --prefix="${yaml_prefix}")"

    if
      ! yaml::validate --element="${yaml_prefix}enabled_repositories" "${yaml[*]}"
    then
      continue
    fi

    if [[ -n "${only_include}" ]]; then
      file_name="$(filesystem::file_name "${file}")"
      file_name="${file_name%.*}.yaml"

      if [[ "${included_list[*]}" =~ ${file_name} ]]; then
        configuration::copy_config_file \
          --config_file="${file}" \
          --rename="${rename}" \
          --use_symlink=false
      fi
    else
      configuration::copy_config_file \
        --config_file="${file}" \
        --use_symlink=false
    fi
  done
}
