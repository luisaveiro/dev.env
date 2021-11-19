# shellcheck shell=bash
#
# Simple package manager to load third-party packages.

export readonly PACKAGES_DIR="${CURRENT_DIR}/packages"

readonly PACKAGES=(
  "ansi/ansi.sh"
  "git/git.sh"
  "help/help.sh"
)

#######################################
# Check if package exists.
#
# Globals:
#   PACKAGES_DIR
#
# Arguments:
#   package
#
# Returns:
#   0 if package exists.
#   1 if package does not exists.
#######################################
function package::exists() {
  [ -f "${PACKAGES_DIR}/${1}" ] && return 0 || return 1
}

#######################################
# Execute package command.
#
# Arguments:
#   --package
#   --command
#   arguments
#######################################
function package::execute_command() {
  local arguments_list=("package" "command")
  local package command arguments

  arguments=$*

  while [ $# -gt 0 ]; do
    if [[ $1 == *"--"* && $1 == *"="* ]]; then
      local argument="${1/--/}"
      IFS='=' read -ra parameter <<< "${argument}"

      if [[ "${arguments_list[*]}" =~ ${parameter[0]} ]]; then
        arguments="${arguments/--${argument}/}"
        declare "${parameter[0]}"="${parameter[1]}"
      fi
    fi

    shift
  done

  IFS=' ' read -ra arguments <<< "${arguments}"

  "package::${package}" "${command}" "${arguments[@]}"
}

#######################################
# Load package shell script.
#
# Globals:
#   PACKAGES_DIR
#
# Arguments:
#   package
#
# Returns:
#   1 if package does not exists.
#######################################
function package::load() {
  local package=$1

  if ! package::exists "${package}"; then
    error --newline=top \
      "The $(ansi --bold --white "$( dirname "${package}")")" \
      "package does not exists."

    exit 1
  fi

  # shellcheck source=/dev/null
  source "${PACKAGES_DIR}/${package}"
}

#######################################
# Main packages shell script.
#
# Globals:
#   PACKAGES_DIR
#
# Arguments:
#   packages
#######################################
function package::main() {
  for package in "$@"
  do
    # shellcheck source=/dev/null
    source "${PACKAGES_DIR}/${package}"
  done
}

package::main "${PACKAGES[@]}"
