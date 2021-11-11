# shellcheck shell=bash
#
# Repos package setup command.

#######################################
# Setup Git Repository from repositories YAML file.
#
# Arguments:
#   repository
#
# Returns:
#   1 if repositories file does not exists in directory
#   or repository does not exist in repositories YAML file.
#######################################
function repos::status() {
  local repository_file yaml yaml_enabled_repositories=() prefix="yaml_"
  local status="red" installed_repositories=0 repositories=()

  repository_file="$(pwd)/repositories.yml"

  if ! file_exists "${repository_file}"; then
    warning "Add $(ansi --bold --white repositories.yml)" \
      "before running repos:setup."

    info "Use the following commands:" \
      "$(ansi --bold --white repos:publish) or" \
      "$(ansi --bold --white repos:publish "<template>")."

    exit 1
  fi

  info "[1/2] Retriving $(ansi --bold --white repositories.yml)"

  # parse the yaml file.
  yaml="$(yaml::parse_yaml --file="${repository_file}" --prefix="${prefix}")"

  info --overwrite "[1/2] Retriving $(ansi --bold --white repositories.yml)" \
    "$(ansi --bold --white "[OK]")"

  info "[2/2] Validating YAML configuration ..."

  progressbar::start
  progressbar::half

  if ! yaml::validate --element="${prefix}enabled_repositories" "${yaml[*]}";
  then
    progressbar::finish --clear

    info --overwrite "[2/2] Validating YAML configuration" \
    "$(ansi --bold --red "[FAILED]")"

    error --newline=top --newline=bottom \
      "Your $(ansi --bold --white repositories.yml) is not valid."

    info "Please add $(ansi --bold --white enabled-repositories) element list" \
      "in your $(ansi --bold --white repositories.yml)" \
      "and add the repositories you want to setup to the list."

    exit 1
  fi

  # Create variables of yaml elements.
  eval "${yaml[*]}"

  progressbar::finish --clear

  local undiscovered_repositories=()
  for enabled_repository in "${yaml_enabled_repositories[@]}"
  do
    # Add yaml prefix for yaml element.
    repository_element=${prefix}${enabled_repository}

    # YAML parse replace yaml element hyphen, fullstop with underscore symbol.
    repository_element="${repository_element//[-.]/_}"

    if [[ $yaml != *"${repository_element}"* ]]; then
      undiscovered_repositories+=("${enabled_repository}")
    fi
  done

  if [[ ${#undiscovered_repositories[@]} -gt 0 ]]; then
    info --overwrite "[2/2] Validating YAML configuration" \
    "$(ansi --bold --red "[FAILED]")"

    error --newline=top --newline=bottom \
      "Your $(ansi --bold --white repositories.yml) is not valid."

    if [[ ${#undiscovered_repositories[@]} -eq 1 ]]; then
      output "The ${undiscovered_repositories[*]} repository is missing" \
        "from enabled repositories"
    else
      output --newline=bottom \
        "The following repositories are missing from enabled repositories:"

      for undiscovered_repository in "${undiscovered_repositories[@]}"
      do
        output "$(ansi --white --bold - "${undiscovered_repository}")"
      done
    fi

    exit 1
  fi

  info --overwrite --newline=bottom "[2/2] Validating YAML configuration" \
    "$(ansi --bold --white "[OK]")"

  for enabled_repository in "${yaml_enabled_repositories[@]}"
  do
    # Add yaml prefix for yaml element.
    repository_element=${prefix}${enabled_repository}

    # YAML parse replace yaml element hyphen, fullstop with underscore symbol.
    repository_element="${repository_element//[-.]/_}"

    # dynamicly create variable names
    repository_git=${repository_element}_gitUrl
    repository_dir=${repository_element}_localDirectory

    if [[ -z ${!repository_dir} ]]; then
      dir="$(git::repository "${!repository_git}")"
    else
      dir="${!repository_dir}"
    fi

    if directory_exists "$(pwd)/${dir}"; then
      cloned="Yes"
      installed_repositories=$((installed_repositories + 1))
    else
      cloned="No"
    fi

    repositories+=(
      "$(git::hostname "${!repository_git}")"
      "$(git::user "${!repository_git}")"
      "${enabled_repository}"
      "${dir}"
      "${cloned}"
    )
  done

  if [[ ${installed_repositories} -gt 0 ]]; then
    [[ ${installed_repositories} -lt  ${#yaml_enabled_repositories[@]} ]] &&
      status="yellow" || status="green"
  fi

  # shellcheck disable=SC2059
  printf "$(ansi --white --bold %-18s) $(ansi --green --bold %3d) \n" \
    "- Total Enabled" "${#yaml_enabled_repositories[@]}"

  # shellcheck disable=SC2059
  printf "$(ansi --white --bold %-18s) $(ansi --${status} --bold %3d) \n" \
    "- Total Installed" "${installed_repositories}"

  newline

  table::row_numbers true
  table::header_style "--green"
  table::header "Git Remote" "Git User" "Repository Name" "Directory" "Cloned"
  table::records "${repositories[@]}"
  table::display

  if [[ ${installed_repositories} -lt  ${#yaml_enabled_repositories[@]} ]]; then
    info --newline=top \
      "Use the following commands to setup outstanding repositories:" \
      "$(ansi --bold --white repos:setup) or" \
      "$(ansi --bold --white repos:setup "<repository-name>")"
  fi
}
