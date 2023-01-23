# shellcheck shell=bash
#
# Load DEV.env Repos module repo configuration service functions.

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
function repo_configuration::copy_config_file() {
  local arguments_list=("config_file" "rename" "use_symlink")
  local config_file
  local file_extension
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

  file_extension="$(filesystem::file_extension "${config_file}")"

  if [[ "${file_extension}" != "yml" && "${file_extension}" != "yaml" ]]; then
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
      return
    fi

    rm "${TEMPLATE_DIR}/${file_name}"

    console::info --margin-top --margin-bottom \
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

  console::output \
    "Use the following command to publish your YAML repository configuration" \
    "file: $(ansi --bold --white repos:publish "${file_name%.*}")."
}
