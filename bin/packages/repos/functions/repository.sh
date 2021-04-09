# shellcheck shell=bash
#
# Repos package git functions.

#######################################
# Clone and configure repository
#
# Arguments:
#   --repository
#   --branch
#   --dir
#   --git
#   --setup_command
#
# Returns:
#   1 if repository directory exists.
#######################################
function repository::clone() {
  local arguments_list=("repository" "branch" "dir" "git" "setup_command")
  local repository git dir branch setup_command

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

  info "[1/4] Preparing setting up"
  info "[2/4] Validating repository configuration ..."

  progressbar::start
  progressbar::half

  if [[ -z $git ]]; then
    progressbar::clear

    warning "Repository missing $(ansi --bold --white "Git url")" \
      "Please add $(ansi --bold --white gitUrl) element."

    return
  fi

  progressbar::finish --clear

  info --overwrite "[2/4] Validating configuration" \
    "$(ansi --bold --white "[OK]")"

  if [[ -z $dir ]]; then
    dir="$(git::repository "${git}")"
  fi

  info "[3/4] Cloning $(ansi --bold --white "${repository}")" \
    "$(ansi --bold --white "[PROCESSING]")"

  if directory_exists "$(pwd)/${dir}"; then
    info --overwrite "[3/4] Repository already exists in directory:" \
      "$(ansi --bold --white "${dir}"). $(ansi --bold --yellow "[SKIPPING]")"

    return
  fi

  if ! git::clone --quiet --git="${git}" --dir="${dir}" --branch="${branch}";
  then
    info --overwrite --newline=bottom \
      "[3/4] Cloning $(ansi --bold --white "${repository}")" \
      "$(ansi --bold --red "[FAILED]")"

    error "Repository not found. Could not read from remote repository."
    output "Please make sure you have the correct access rights" \
      "and the repository exists."

    return
  fi

  info --overwrite "[3/4] Cloning $(ansi --bold --white "${repository}")" \
    "$(ansi --bold --green "[COMPLETED]")"

  if [[ -z ${setup_command} ]]; then
    info "[4/4] Repository does not have setup command" \
      "$(ansi --bold --yellow "[SKIPPING]")"

    return
  fi

  info "[4/4] Execute setup command ..."

  IFS=' ' read -ra setup_command <<< "${setup_command}"

  _=$(cd "$(pwd)/${dir}" && "${setup_command[@]}" 2>&1)

  info --overwrite "[4/4] Execute setup command" \
    "$(ansi --bold --green "[COMPLETED]")"
}
