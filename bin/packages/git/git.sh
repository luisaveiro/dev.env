# shellcheck shell=bash
#
# Package with helpful git commands.

GIT_REGEX="^(https|git)(:\/\/|@)([^\/:]+)[\/:]([^\/:]+)\/(.+).git$"
GIST_REGEX="^(https|git)(:\/\/|@)([^\/:]+)[\/:](.+).git$"

#######################################
# Git clone repository
#
# Arguments:
#   --branch
#   --dir
#   --git
#   flags
#
# Returns:
#   1 git clone fails or if repository directory exists.
#   0 git clone successful.
#######################################
function git::clone() {
  local arguments_list=("branch" "dir" "git")
  local git dir branch command flags=$*

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

  IFS=' ' read -ra flags <<< "${flags}"

  if [[ -n $branch ]]; then
    branch="--branch ${branch}"
  fi

  if [[ -z $dir ]]; then
    dir="$(basename "${git}" .git)"
  fi

  if directory_exists "$(pwd)/${dir}"; then
    return 1
  fi

  parameters="${flags[*]} ${git} ${dir} ${branch}"

  IFS=' ' read -ra parameters <<< "${parameters}"

  command=$(git clone "${parameters[@]}" 2>&1)

  [[ -n $command ]] && return 1 || return 0
}

#######################################
# Get the Git hostname.
#
# Global:
#   GIST_REGEX
#
# Arguments:
#   git url
#
# Outputs:
#   git hostname
#######################################
function git::gist_hash() {
  if [[ $1 =~ ${GIST_REGEX} ]]; then
    echo "${BASH_REMATCH[4]}"
  fi
}

#######################################
# Get the Git hostname.
#
# Global:
#   GIT_REGEX
#
# Arguments:
#   git url
#
# Outputs:
#   git hostname
#######################################
function git::hostname() {
  if [[ $1 =~ ${GIT_REGEX} ]]; then
    echo "${BASH_REMATCH[3]}"
  fi
}

#######################################
# Check if Git is installed on machine.
#
# Returns:
#   0 if git is installed.
#   1 if git is not installed.
#######################################
function git::is_installed() {
  if ! git --version > /dev/null 2>&1; then
    return 1
  fi

  return 0
}

#######################################
# Get the latest Git tag.
#
# Arguments:
#   --dir
#
# Outputs:
#   git latest tag.
#######################################
function git::latest_tag() {
  local arguments_list=("dir")
  local dir git_sub_command

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

  if directory_exists "${dir}/.git"; then
    git_sub_command="$(cd "${dir}" && git rev-list --tags --max-count=1)"

    echo -e "$(cd "${dir}" && git describe --tags "$git_sub_command")"
  else
    echo "unreleased"
  fi
}

#######################################
# Get the Git protocol.
#
# Global:
#   GIT_REGEX
#   GIST_REGEX
#
# Arguments:
#   git url
#
# Outputs:
#   git protocol
#######################################
function git::protocol() {
  if [[ $1 =~ ${GIT_REGEX} ]]; then
    echo "${BASH_REMATCH[1]}"
  elif [[ $1 =~ ${GIST_REGEX} ]]; then
    echo "${BASH_REMATCH[1]}"
  fi
}

#######################################
# Get the Git repository.
#
# Global:
#   GIT_REGEX
#
# Arguments:
#   git url
#
# Outputs:
#   git repository
#######################################
function git::repository() {
  if [[ $1 =~ ${GIT_REGEX} ]]; then
    echo "${BASH_REMATCH[5]}"
  fi
}

#######################################
# Get the Git user.
#
# Global:
#   GIT_REGEX
#
# Arguments:
#   git url
#
# Outputs:
#   git user
#######################################
function git::user() {
  if [[ $1 =~ ${GIT_REGEX} ]]; then
    echo "${BASH_REMATCH[4]}"
  fi
}
