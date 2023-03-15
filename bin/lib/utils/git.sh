# shellcheck shell=bash
#
# DEV.env internal Git functions.

#######################################
# Get the repository's checked out
# branch.
#
# Arguments:
#   --dir
#
# Outputs:
#   The checked out branch.
#######################################
function git::active_branch() {
  local dir

  while [ $# -gt 0 ]; do
    if [[ "${1}" == *"--dir="* ]]; then
      local argument="${1/--/}"
      IFS='=' read -ra parameter <<< "${argument}"

      declare "${parameter[0]}"="${parameter[1]}"
    fi

    shift
  done

  if filesystem::does_directory_exists "${dir}/.git"; then
    console::output "$( cd "${dir}" && git branch --show-current )"
  else
    console::output "unreleased"
  fi
}

#######################################
# Checkout a branch for the repository.
#
# Arguments:
#   --dir
#   --branch
#
# Returns:
#   0 if Git checkout successful.
#   1 if Git checkout fails.
#######################################
function git::checkout() {
  local arguments_list=("dir" "branch")
  local branch
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

  unset arguments_list

  command=$( cd "${dir}" && git checkout "${branch}" 2>&1 )

  [[ -n $command ]] && return 1 || return 0
}

#######################################
# Clone Git repository.
#
# Arguments:
#   --branch
#   --dir
#   --repo
#   flags
#
# Returns:
#   0 Git clone successful.
#   1 Git clone fails or if repository
#   directory exists.
#######################################
function git::clone() {
  local arguments_list=("branch" "dir" "repo")
  local branch
  local dir
  local flags="${*}"
  local git_command
  local git_command_parameters
  local repo

  while [ $# -gt 0 ]; do
    if [[ $1 == *"--"* && $1 == *"="* ]]; then
      local argument="${1/--/}"
      IFS='=' read -ra parameter <<< "${argument}"

      if [[ "${arguments_list[*]}" =~ ${parameter[0]} ]]; then
        flags="${flags/--${argument}/}"
        declare "${parameter[0]}"="${parameter[1]}"
      fi
    fi

    shift
  done

  unset arguments_list

  IFS=' ' read -ra flags <<< "${flags}"

  if [[ -n "${branch}" ]]; then
    branch="--branch ${branch}"
  fi

  git_command_parameters="${flags[*]} ${repo} ${dir} ${branch}"

  IFS=' ' read -ra git_command_parameters <<< "${git_command_parameters}"

  git_command=$(git clone "${git_command_parameters[@]}" 2>&1)

  [[ -n $git_command ]] && return 1 || return 0
}

#######################################
# Download objects and refs from the
# repository's remote.
#
# Arguments:
#   --dir
#######################################
function git::fetch() {
  local dir

  while [ $# -gt 0 ]; do
    if [[ $1 == *"--dir="* ]]; then
      local argument="${1/--/}"
      IFS='=' read -ra parameter <<< "${argument}"

      declare "${parameter[0]}"="${parameter[1]}"
    fi

    shift
  done

  _="$( cd "${dir}" && git fetch --all 2>&1 )"
}

#######################################
# Get the Git Remote URL for a
# repository.
#
# Arguments:
#   --dir
#   --remote
#
# Outputs:
#   Git Remote Url.
#######################################
function git::get_remote_url() {
  local arguments_list=("dir" "remote")
  local dir
  local remote=origin

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

  console::output "$(cd "${dir}" && git remote get-url --all "${remote}")"
}

#######################################
# Get the Git repository name.
#
# Global:
#   GIT_REGEX
#
# Arguments:
#   Git Remote URL
#
# Outputs:
#   Git repository name.
#######################################
function git::get_repository_name() {
  if [[ $1 =~ ${GIT_REGEX} ]]; then
    console::output "${BASH_REMATCH[5]}"
  fi
}

#######################################
# Get the Git repository server.
#
# Global:
#   GIT_REGEX
#
# Arguments:
#   Git Remote URL
#
# Outputs:
#   Git repository server name.
#######################################
function git::get_repository_server() {
  if [[ $1 =~ ${GIT_REGEX} ]]; then
    echo "${BASH_REMATCH[3]}"
  fi
}

#######################################
# Get the Git repository user.
#
# Global:
#   GIT_REGEX
#
# Arguments:
#   Git Remote URL
#
# Outputs:
#   Git repository user.
#######################################
function git::get_repository_user() {
  if [[ $1 =~ ${GIT_REGEX} ]]; then
    console::output "${BASH_REMATCH[4]}"
  fi
}


#######################################
# Check if Git Remote URL is valid.
#
# Arguments:
#   Git URL
#
# Returns:
#   0 if Git URL is valid.
#   1 if Git URL is not valid.
#######################################
function git::is_valid_git_url() {
  [[ $1 =~ ^(https:\/\/|git@) && $1 == *".git"  ]] && return 0 || return 1
}

#######################################
# Get the repository's latest tag.
#
# Arguments:
#   --dir
#
# Outputs:
#   The repository's latest tag.
#######################################
function git::latest_tag() {
  local commit_hash
  local dir

  while [ $# -gt 0 ]; do
    if [[ $1 == *"--dir="* ]]; then
      local argument="${1/--/}"
      IFS='=' read -ra parameter <<< "${argument}"

      declare "${parameter[0]}"="${parameter[1]}"
    fi

    shift
  done

  if filesystem::does_directory_exists "${dir}/.git"; then
    commit_hash="$( cd "${dir}" && git rev-list --tags --max-count=1 )"

    if [[ -z "${commit_hash}" ]]; then
      git::active_branch --dir="${dir}"
    else
      console::output "$( cd "${dir}" && git describe --tags "${commit_hash}" )"
    fi
  else
    console::output "unreleased"
  fi
}

#######################################
# Get the timestamp of the repository's
# tag.
#
# Arguments:
#   --dir
#   --tag
#
# Outputs:
#   The timestamp of the repository's
#   tag.
#######################################
function git::tag_timestamp() {
  local arguments_list=("dir" "tag")
  local dir
  local tag

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

  if filesystem::does_directory_exists "${dir}/.git"; then
    console::output "$( cd "${dir}" && git log -1 --format=%ai "${tag}" )"
  else
    console::output "0000-00-00 00:00:00"
  fi
}
