# shellcheck shell=bash
#
# Load DEV.env Repos module repository service functions.

#######################################
# Clone a repository.
#
# Globals:
#   APP_COMMAND
#   REPOS_YAML
#
# Arguments:
#   --branch
#   --dir
#   --git_repo_url
#   --repository
#   --setup_command
#
# Outputs:
#   Writes messages to stdout.
#######################################
function repository::clone() {
  local arguments_list=(
    "branch"
    "dir"
    "git_repo_url"
    "repository"
    "setup_command"
  )
  local branch
  local dir
  local git_repo_url
  local repository
  local setup_command

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

  console::output --margin-top --margin-bottom \
    "$(ansi --bold --white SETUP:)" \
    "Preparing to set up $(ansi --bold --white "${repository}") ..."

  console::info \
    "[1/3] Validating repository configuration ..."

  progressbar::start

  if [[ -z "${git_repo_url}" ]]; then
    progressbar::finish --clear

    console::info --overwrite \
      "[1/3] Validating repository configuration." \
      "$(ansi --bold --red "[FAILED]")"

    console::error --margin-top \
      "Repository $(ansi --bold --white "${repository}") is missing Git" \
      "Remote URL. Please add the \"$(ansi --bold --white gitUrl)\" element" \
      "in your $(ansi --bold --white "${REPOS_YAML}")"

    return
  fi

  progressbar::half

  if ! git::is_valid_git_url "${git_repo_url}"; then
    progressbar::finish --clear

    console::info --overwrite \
      "[1/3] Validating repository configuration." \
      "$(ansi --bold --red "[FAILED]")"

    console::error --margin-top --margin-bottom \
      "Repository $(ansi --bold --white "${repository}") Git Remote URL" \
      "is not valid. The Git Remote URL provided:" \
      "$(ansi --bold --white "${git_repo_url}")."

    console::output --margin-bottom \
      "There are two types of Git Remote URL addresses:"

    console::output "- An HTTPS URL, e.g." \
      "$(ansi --bold --white "https://github.com/user/repo.git")"

    console::output "- An SSH URL, e.g." \
      "$(ansi --bold --white "git@github.com:user/repo.git")"

    return
  fi

  progressbar::finish --clear

  console::info --overwrite \
    "[1/3] Validating repository configuration." \
    "$(ansi --bold --white "[OK]")"

  console::info \
    "[2/3] Attempting to clone $(ansi --bold --white "${repository}") ..."

  progressbar::start
  progressbar::half

  if [[ -z "${dir}" ]]; then
    dir="$(git::get_repository_name "${git_repo_url}")"
  fi

  dir="$(pwd)/${dir/\//}"

  if filesystem::does_directory_exists "${dir}/.git"; then
    progressbar::finish --clear

    console::info --overwrite \
      "[2/3] Attempting to clone $(ansi --bold --white "${repository}")." \
      "$(ansi --bold --yellow "[SKIPPING]")"

    existing_project="$(git::get_remote_url --dir="${dir}" --remote=origin)"

    if [[ "${existing_project}" == "${git_repo_url}" ]]; then
      console::warning --margin-top \
        "Repository $(ansi --bold --white "${repository}") already exists in" \
        "directory: \"$(ansi --bold --white "${dir}")\"."
    else
      console::error --margin-top \
        "Another repository already exists in directory:" \
        "\"$(ansi --bold --white "${dir}")\"."
    fi

    return
  fi

  if
    filesystem::does_directory_exists "${dir}" &&
    ! filesystem::is_directory_empty "${dir}"
  then
    progressbar::finish --clear

    console::info --overwrite \
      "[2/3] Attempting to clone $(ansi --bold --white "${repository}")." \
      "$(ansi --bold --red "[FAILED]")"

    console::error --margin-top \
      "Directory: \"$(ansi --bold --white "${dir}")\" is not empty. Unable to" \
      "clone $(ansi --bold --white "${repository}") in targeted directory."

    return
  fi

  if
    ! git::clone \
      --quiet \
      --repo="${git_repo_url}" \
      --dir="${dir}" \
      --branch="${branch}"
  then
    progressbar::finish --clear

    console::info --overwrite \
      "[2/3] Attempting to clone" \
      "$(ansi --bold --white "${repository}")." \
      "$(ansi --bold --red "[FAILED]")"

    console::error --margin-top --margin-bottom \
      "Remote repository ($(ansi --bold --white "${git_repo_url}"))" \
      "not found. Could not read from remote repository."

    console::output \
      "Please make sure you have the correct access rights and the remote" \
      "repository exists."

    exit 1
  fi

  progressbar::finish --clear

  console::info --overwrite \
    "[2/3] Attempting to clone" \
    "$(ansi --bold --white "${repository}")." \
    "$(ansi --bold --white "[OK]")"

  console::info "[3/3] Attempting to execute setup command ..."

  if [[ -z "${setup_command}" ]]; then
    console::info --overwrite \
      "[3/3] Attempting to execute setup command." \
      "$(ansi --bold --yellow "[SKIPPING]")"

    console::output --margin-top \
      "$(ansi --bold --white "${repository}") does not have a setup command."

    return
  fi

  IFS=' ' read -ra setup_command <<< "${setup_command}"

  _=$(cd "${dir}" && "${setup_command[@]}" 2>&1)

  console::info --overwrite \
    "[3/3] Attempting to execute setup command." \
    "$(ansi --bold --green "[COMPLETED]")"
}
