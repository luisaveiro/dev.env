# shellcheck shell=bash
#
# DEV.env Repos module setup command.

#######################################
# List available templates for
# repositories
#
# Globals:
#   APP_NAME
#   APP_COMMAND
#   HOME
#   PROJECT_DIR
#   REPOS_YAML
#
# Arguments:
#   User input
#
# Outputs:
#   Writes messages to stdout.
#######################################
function repos::command_setup() {
  local repository="${1}"
  local repos_file
  local yaml
  local yaml_enabled_repositories=()
  local yaml_prefix="yaml_"

  if [[ "$(pwd)" == "${PROJECT_DIR}" ]]; then
    console::warning --margin-bottom \
      "It is not recommended to install your repositories within" \
      "$(ansi --bold --white "${APP_NAME}") source code."

    console::output \
      "As a suggestion, you can create a \"$(ansi --bold --white Dev)\" folder" \
      "in your username home directory \"$(ansi --bold --white "${HOME}")\"." \
      "Use the following command:" \
      "$(ansi --bold --white "mkdir -p ~/Dev && cd ~/Dev && ${APP_COMMAND} repos:setup")."

    exit 1
  fi

  repos_file="$(pwd)/${REPOS_YAML}"

  if ! filesystem::does_file_exists "${repos_file}"; then
    if
      symlink::is_symlink "${repos_file}" &&
      ! symlink::is_valid "${repos_file}"
    then
      console::error --margin-bottom \
        "The $(ansi --bold --white "${REPOS_YAML}") is a broken symbolic link."

      console::output --margin-bottom \
        "The symbolic link target" \
        "\"$(ansi --bold --white "$(symlink::target "${repos_file}")")\"" \
        "is missing."

      question="Do you want to delete the invalid YAML repository "
      question+="configuration file, (${REPOS_YAML})?"

      if console::ask --message="${question}" --default="N"; then
        rm "${repos_file}"

        console::info --margin-top \
          "Deleted $(ansi --bold --white "${repos_file}") YAML repository" \
          "configuration file!"
      fi

      exit 1
    fi

    if ! filesystem::does_file_exists "${repos_file%.*}.yml"; then
      console::error --margin-bottom \
        "The $(ansi --bold --white "${REPOS_YAML}") does not exists."

      console::output \
        "To add $(ansi --bold --white "${REPOS_YAML}") use the following commands:" \
        "$(ansi --bold --white "${APP_COMMAND}" repos:publish) or" \
        "$(ansi --bold --white "${APP_COMMAND}" repos:publish "<template-name>")."

        exit 1
    fi

    mv "${repos_file%.*}.yml" "${repos_file}"
  fi

  console::info "[1/3] Retriving $(ansi --bold --white "${REPOS_YAML}") ..."

  progressbar::start

  # Parse the repositories.yaml file.
  yaml="$(yaml::parse_yaml --file="${repos_file}" --prefix="${yaml_prefix}")"

  progressbar::half
  progressbar::finish --clear

  console::info --overwrite \
    "[1/3] Retriving $(ansi --bold --white "${REPOS_YAML}")." \
    "$(ansi --bold --white "[OK]")"

  console::info "[2/3] Validating YAML configuration ..."

  progressbar::start
  progressbar::half

  if
    [[ -z $repository ]] &&
    ! yaml::validate --element="${yaml_prefix}enabled_repositories" "${yaml[*]}"
  then
    progressbar::finish --clear

    console::info --overwrite \
      "[2/3] Validating YAML configuration. $(ansi --bold --red "[FAILED]")"

    console::error --margin-top --margin-bottom \
      "Your $(ansi --bold --white "${REPOS_YAML}") is not valid."

    console::output \
      "Please add \"$(ansi --bold --white enabled-repositories)\" element" \
      "list in your $(ansi --bold --white "${REPOS_YAML}")" \
      "and add the repositories you want to setup to the list."

    exit 1
  fi

  progressbar::finish --clear

  console::info --overwrite \
    "[2/3] Validating YAML configuration. $(ansi --bold --white "[OK]")"

  # Create variables of yaml elements.
  eval "${yaml[*]}"

  if [[ -z $repository ]]; then
    if [[ ${#yaml_enabled_repositories[@]} -eq 0 ]]; then
      console::error --margin-top --margin-bottom \
        "[3/3] Found $(ansi --bold --white "${#yaml_enabled_repositories[@]}")" \
        "enabled repositories."

      console::output \
        "Please add the repositories you want to setup to" \
        "\"$(ansi --bold --white enabled-repositories)\" element list in your" \
        "$(ansi --bold --white "${REPOS_YAML}")."

      console::output \
        "Alternatively, you can provide the name of individual repos to setup:" \
        "$(ansi --bold --white repos:setup "<repository-name>")."

      exit 1
    fi

    if [[ ${#yaml_enabled_repositories[@]} -eq 1 ]]; then
      console::info --margin-bottom \
        "[3/3] Found $(ansi --bold --white 1) enabled repository."
    else
      console::info --margin-bottom \
        "[3/3] Found $(ansi --bold --white "${#yaml_enabled_repositories[@]}")" \
        "enabled repositories."
    fi

    printf -- '- %s\n' "${yaml_enabled_repositories[@]}"

    for enabled_repository in "${yaml_enabled_repositories[@]}"; do
      # Add yaml prefix for yaml element.
      repository_element=${yaml_prefix}${enabled_repository}

      # YAML parse replace yaml element hyphen, fullstop with underscore symbol.
      repository_element="${repository_element//[-.]/_}"

      if [[ $yaml != *"${repository_element}"* ]]; then
        console::warning --margin-top \
          "Repository $(ansi --bold --white "${enabled_repository}")" \
          "not found in $(ansi --bold --white "${REPOS_YAML}")." \
          "$(ansi --bold --yellow "[SKIPPING]")"

        continue
      fi

      # dynamicly create variable names
      repository_git_repo_url=${repository_element}_gitUrl
      repository_directory=${repository_element}_localDirectory
      repository_branch=${repository_element}_branch
      repository_setup=${repository_element}_setupCommand

      repository::clone \
        --repository="${enabled_repository}" \
        --git_repo_url="${!repository_git_repo_url}" \
        --dir="${!repository_directory}" \
        --branch="${!repository_branch}" \
        --setup_command="${!repository_setup}"
    done
  else
    console::info \
      "[3/3] Searching for $(ansi --bold --white "${repository}") ..."

    # Add yaml prefix for yaml element.
    repository_element=${yaml_prefix}${repository}

    # YAML parse replace yaml element hyphen, fullstop with underscore symbol.
    repository_element="${repository_element//[-.]/_}"

    if [[ $yaml != *"${repository_element}"* ]]; then
      console::info --overwrite \
        "[3/3] Searching for $(ansi --bold --white "${repository}")." \
        "$(ansi --bold --red "[FAILED]")"

      console::error --margin-top \
        "Repository $(ansi --bold --white "${repository}")" \
        "not found in $(ansi --bold --white "${REPOS_YAML}")."

      exit 1
    fi

    console::info --overwrite \
      "[3/3] Searching for $(ansi --bold --white "${repository}")." \
      "$(ansi --bold --white "[OK]")"

    # dynamicly create variable names
    repository_git_repo_url=${repository_element}_gitUrl
    repository_directory=${repository_element}_localDirectory
    repository_branch=${repository_element}_branch
    repository_setup=${repository_element}_setupCommand

    repository::clone \
      --repository="${repository}" \
      --git_repo_url="${!repository_git_repo_url}" \
      --dir="${!repository_directory}" \
      --branch="${!repository_branch}" \
      --setup_command="${!repository_setup}"
  fi
}
