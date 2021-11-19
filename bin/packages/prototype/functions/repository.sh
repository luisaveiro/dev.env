# shellcheck shell=bash
#
# Prototype package repository functions.

#######################################
# Clone Awesome Docker Compose samples
#
# Arguments:
#   --dir
#   --git
#######################################
function repository::clone() {
  local arguments_list=("dir" "git")
  local dir git

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

  info "[1/1] Cloning $(ansi --bold --white "${git}")" \
    "$(ansi --bold --white "[PROCESSING]")"

  if ! git::clone --quiet --git="${git}" --dir="${dir}"; then
    info --overwrite --newline=bottom \
      "[1/1] Cloning $(ansi --bold --white "${git}")" \
      "$(ansi --bold --red "[FAILED]")"

    error "Repository not found. Could not read from remote repository."
    output "Please make sure you have the correct access rights" \
      "and the repository exists."

    return
  fi

  info --overwrite \
    "[1/1] Cloning $(ansi --bold --white "${git}")" \
    "$(ansi --bold --green "[COMPLETED]")"
}

#######################################
# Update Awesome Docker Compose samples
#
# Arguments:
#   --dir
#######################################
function repository::update() {
  local arguments_list=("dir")
  local dir

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

  info "[1/1] Updating $(ansi --bold --white Awesome Docker Compose samples)" \
    "$(ansi --bold --white "[PROCESSING]")"

  git::fetch --dir="${dir}"

  info --overwrite \
    "[1/1] Updating $(ansi --bold --white Awesome Docker Compose samples)" \
    "$(ansi --bold --green "[COMPLETED]")"
}
