# shellcheck shell=bash
# shellcheck disable=SC2059
#
# DEV.env Repos module status command.

#######################################
# List all Git repositories from the
# repositories file and the setup
# status.
#
# Globals:
#   APP_COMMAND
#   REPOS_YAML
#
# Outputs:
#   Writes list of repositories files
#   to stdout.
#
# Returns:
#   1 if the repositories file does not
#   exists in directory or repositories
#   YAML file is not valid.
#######################################
function repos::command_status() {
  local listed_repositories
  local installed_repositories=0
  local invalid_repositories=()
  local repos_file
  local repositories=()
  local undiscovered_repositories=()
  local yaml
  local yaml_enabled_repositories=()
  local yaml_prefix="yaml_"

  repos_file="$(pwd)/${REPOS_YAML}"

  if ! filesystem::does_file_exists "${repos_file}"; then
    console::error --margin-bottom \
      "$(ansi --bold --white "${REPOS_YAML}") does not exist."

    console::output \
      "Please add $(ansi --bold --white "${REPOS_YAML}")" \
      "before running the repos:status command. Use the following" \
      "command: $(ansi --bold --white "${APP_COMMAND} repos:publish")."

      exit 1
  fi

  console::info "[1/2] Retriving $(ansi --bold --white "${REPOS_YAML}") ..."

  progressbar::start

  # Parse the repositories.yaml file.
  yaml="$(yaml::parse_yaml --file="${repos_file}" --prefix="${yaml_prefix}")"

  progressbar::half
  progressbar::finish --clear

  console::info --overwrite \
    "[1/2] Retriving $(ansi --bold --white "${REPOS_YAML}")" \
    "$(ansi --bold --white "[OK]")"

  console::info "[2/2] Validating YAML configuration ..."

  progressbar::start

  if
   ! yaml::validate --element="${yaml_prefix}enabled_repositories" "${yaml[*]}"
  then
    progressbar::finish --clear

    console::info --overwrite \
      "[2/2] Validating YAML configuration. $(ansi --bold --red "[FAILED]")"

    console::error --margin-top --margin-bottom \
      "Your $(ansi --bold --white "${REPOS_YAML}") is not valid."

    console::output \
      "Please add \"$(ansi --bold --white enabled-repositories)\" element" \
      "list in your $(ansi --bold --white "${REPOS_YAML}")" \
      "and add the repositories you want to setup to the list."

    exit 1
  fi

  # Create variables of yaml elements.
  eval "${yaml[*]}"

  for enabled_repository in "${yaml_enabled_repositories[@]}"; do
    # Add yaml prefix for yaml element.
    repository_element=${yaml_prefix}${enabled_repository}

    # YAML parse replace yaml element hyphen, fullstop with underscore symbol.
    repository_element="${repository_element//[-.]/_}"

    if [[ $yaml != *"${repository_element}"* ]]; then
      undiscovered_repositories+=("${enabled_repository}")
    fi
  done

  if [[ ${#undiscovered_repositories[@]} -gt 0 ]]; then
    progressbar::finish --clear

    console::info --overwrite \
      "[2/2] Validating YAML configuration $(ansi --bold --red "[FAILED]")"

    console::error --margin-top --margin-bottom \
      "Your $(ansi --bold --white "${REPOS_YAML}") is not valid."

    if [[ ${#undiscovered_repositories[@]} -eq 1 ]]; then
      console::output \
        "The $(ansi --bold --white "${undiscovered_repositories[*]}")" \
        "repository is listed as an enabled repository, but the configuration" \
        "is missing. Please add the configuration."
    else
      console::output --margin-bottom \
        "The following repositories are listed as enabled repositories, but" \
        "the configurations are missing. Please add the configurations."

      printf -- '- %s\n' "${undiscovered_repositories[@]}"
    fi

    exit 1
  fi

  unset undiscovered_repositories

  progressbar::half

  listed_repositories="$(compgen -v -X '!yaml_*_gitUrl')"
  listed_repositories=$(echo "${listed_repositories}" | tr '\n' ' ')
  IFS=' ' read -ra listed_repositories <<< "${listed_repositories}"

  for i in "${!listed_repositories[@]}"; do
    repository="${listed_repositories[$i]}"

    if [[ -z "${!repository}" ]]; then
      repository="${repository//yaml/}"
      repository="${repository//gitUrl/}"
      repository="${repository//_/ }"
      invalid_repositories+=("${repository}")
    fi
  done

  unset listed_repositories

  if [[ ${#invalid_repositories[@]} -gt 0 ]]; then
    progressbar::finish --clear

    console::info --overwrite \
      "[2/2] Validating YAML configuration $(ansi --bold --red "[FAILED]")"

    console::error --margin-top --margin-bottom \
      "Your $(ansi --bold --white "${REPOS_YAML}") is not valid."

    if [[ ${#invalid_repositories[@]} -eq 1 ]]; then
      console::output \
        "Repository $(ansi --bold --white "${invalid_repositories[*]}")" \
        "is missing the Git Remote URL. Please add the" \
        "\"$(ansi --bold --white gitUrl)\" element in your" \
        "$(ansi --bold --white "${REPOS_YAML}")"
    else
      console::output --margin-bottom \
        "The following repositories are missing the Git Remote URL." \
        "Please add the \"$(ansi --bold --white gitUrl)\" element in your" \
        "$(ansi --bold --white "${REPOS_YAML}")"

      printf -- '- %s\n' "${invalid_repositories[@]}"
    fi

    exit 1
  fi

  unset invalid_repositories

  progressbar::finish --clear

  console::info --overwrite --margin-bottom \
    "[2/2] Validating YAML configuration $(ansi --bold --white "[OK]")"


  for enabled_repository in "${yaml_enabled_repositories[@]}"; do
    # Add yaml prefix for yaml element.
    repository_element=${yaml_prefix}${enabled_repository}

    # YAML parse replace yaml element hyphen, fullstop with underscore symbol.
    repository_element="${repository_element//[-.]/_}"

    # dynamicly create variable names
    repository_git=${repository_element}_gitUrl
    repository_dir=${repository_element}_localDirectory

    [[ -z ${!repository_dir} ]] && \
      dir="$(git::get_repository_name "${!repository_git}")" || dir="${!repository_dir}"

    cloned="No"

    if filesystem::does_directory_exists "$(pwd)/${dir}"; then
      cloned="Yes"
      installed_repositories=$((installed_repositories + 1))
    fi

    repositories+=(
      "$(git::get_repository_server "${!repository_git}")"
      "$(git::get_repository_user "${!repository_git}")"
      "${enabled_repository}"
      "${dir}"
      "${cloned}"
    )
  done

  local status="red"

  if [[ ${installed_repositories} -gt 0 ]]; then
    [[ ${installed_repositories} -lt  ${#yaml_enabled_repositories[@]} ]] &&
      status="yellow" || status="green"
  fi

  printf "$(ansi --white --bold %-18s) $(ansi --green --bold %3d) \n" \
    "- Total Enabled" "${#yaml_enabled_repositories[@]}"

  printf "$(ansi --white --bold %-18s) $(ansi --${status} --bold %3d) \n" \
    "- Total Installed" "${installed_repositories}"

  console::newline

  table::set_row_numbers true
  table::set_header_style "--green"
  table::headers "Git Remote" "Git User" "Repository Name" "Directory" "Cloned"
  table::set_records "${repositories[@]}"
  table::display

  total_repositories=${#yaml_enabled_repositories[@]}
  outstanding_repositories="$((total_repositories - installed_repositories))"

  if [[ ${outstanding_repositories} -gt 0 ]]; then
    console::info --margin-top --margin-bottom \
      "You have ${outstanding_repositories} outstanding repositories."

    console::output \
      "Use the following commands to set up the outstanding repositories:" \
      "$(ansi --bold --white "${APP_COMMAND} repos:setup") or" \
      "$(ansi --bold --white "${APP_COMMAND} repos:setup <repository-name>")"
  fi
}
