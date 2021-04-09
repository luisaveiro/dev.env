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
function repos::setup() {
  local repository_file yaml yaml_enabled_repositories=()
  local prefix="yaml_" repository=$*

  repository_file="$(pwd)/repositories.yml"

  if ! file_exists "${repository_file}"; then
    warning "Add $(ansi --bold --white repositories.yml)" \
      "before running repos:setup."

    info "Use the following commands:" \
      "$(ansi --bold --white repos:publish) or" \
      "$(ansi --bold --white repos:publish "<template>")."

    exit 1
  fi

  info "[1/3] Retriving $(ansi --bold --white repositories.yml)"

  # parse the yaml file.
  yaml="$(yaml::parse_yaml --file="${repository_file}" --prefix="${prefix}")"

  info --overwrite "[1/3] Retriving $(ansi --bold --white repositories.yml)" \
    "$(ansi --bold --white "[OK]")"

  info "[2/3] Validating YAML configuration ..."

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

    output "Or use the following command to setup an individual repos:" \
      "$(ansi --bold --white repos:setup "<repository-name>")"

    exit 1
  fi

  progressbar::finish --clear

  info --overwrite "[2/3] Validating YAML configuration" \
    "$(ansi --bold --white "[OK]")"

  # Create variables of yaml elements.
  eval "${yaml[@]}"

  if [[ -z $repository ]]; then
    if [[ ${#yaml_enabled_repositories[@]} -eq 1 ]]; then
      info --newline=bottom "[3/3] Found $(ansi --bold --white 1)" \
        "enabled repository"
    else
      info --newline=bottom "[3/3] Found" \
        "$(ansi --bold --white "${#yaml_enabled_repositories[@]}")" \
        "enabled repositories"
    fi

    printf '\055 %s\n' "${yaml_enabled_repositories[@]}"

    for enabled_repository in "${yaml_enabled_repositories[@]}"
    do
      # Add yaml prefix for yaml element.
      repository_element=${prefix}${enabled_repository}

      # YAML parse replace yaml element hyphen, fullstop with underscore symbol.
      repository_element="${repository_element//[-.]/_}"

      output --newline=top --newline=bottom \
        "$(ansi --white SETUP:) $(ansi --bold --white "${enabled_repository}")"

      if [[ $yaml != *"${repository_element}"* ]]; then
        warning "Repository $(ansi --bold --white "${enabled_repository}")" \
          "not found in $(ansi --bold --white repositories.yml)" \
          "$(ansi --bold --yellow "[SKIPPING]")"

        continue
      fi

      # dynamicly create variable names
      repository_git=${repository_element}_gitUrl
      repository_dir=${repository_element}_localDirectory
      repository_branch=${repository_element}_branch
      repository_setup=${repository_element}_setupCommand

      repository::clone \
        --repository="${enabled_repository}" \
        --git="${!repository_git}" \
        --dir="${!repository_dir}" \
        --branch="${!repository_branch}" \
        --setup_command="${!repository_setup}"
    done
  else
    # Add yaml prefix for yaml element.
    repository_element=${prefix}${repository}

    # YAML parse replace yaml element hyphen, fullstop with underscore symbol.
    repository_element="${repository_element//[-.]/_}"

    # dynamicly create variable names
    repository_git=${repository_element}_gitUrl
    repository_branch=${repository_element}_branch
    repository_dir=${repository_element}_localDirectory
    repository_setup=${repository_element}_setupCommand

    if [[ -z ${!repository_git} ]]; then
      error --newline=top "Repository $(ansi --bold --white "${repository}")" \
        "not found in $(ansi --bold --white repositories.yml)"

      exit 1
    fi

    info "[3/3] Found $(ansi --bold --white "${repository}")"

    output --newline=top --newline=bottom \
      "$(ansi --white SETUP:) $(ansi --bold --white "${repository}")"

    repository::clone \
      --repository="${repository}" \
      --git="${!repository_git}" \
      --dir="${!repository_dir}" \
      --branch="${!repository_branch}" \
      --setup_command="${!repository_setup}"
  fi
}
