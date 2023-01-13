# shellcheck shell=bash
#
# DEV.env internal module functions.

#######################################
# Check if the module exists.
#
# Globals:
#   MODULE_DIR
#
# Arguments:
#   module
#
# Returns:
#   0 if the module exists.
#   1 if the module does not exists.
#######################################
function module::exists() {
  filesystem::does_file_exists "${MODULE_DIR}/${1}" && return 0 || return 1
}

#######################################
# Load module shell script.
#
# Globals:
#   MODULE_DIR
#
# Arguments:
#   module
#
# Returns:
#   1 if the module does not exists.
#######################################
function module::load() {
  local module
  local module_name="${1}"

  module="${module_name}/_${module_name}.sh"

  if ! module::exists "${module}"; then
    console::error --margin-top \
      "The $(ansi --bold --white "${module_name}") module does not exists."

    exit 1
  fi

  # shellcheck source=/dev/null
  source "${MODULE_DIR}/${module}"
}
