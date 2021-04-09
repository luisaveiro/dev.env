# shellcheck shell=bash
#
# Internal file system functions.

#######################################
# Check if directory exists.
#
# Arguments:
#   Directory
#
# Returns:
#   0 if directory exists.
#   1 if directory does not exists.
#######################################
function directory_exists() {
  [ -d "${1}" ] && return 0 || return 1
}

#######################################
# Check if file is exists.
#
# Arguments:
#   File
#
# Returns:
#   0 if file exists.
#   1 if file does not exsits.
#######################################
function file_exists() {
  [ -f "${1}" ] && return 0 || return 1
}

#######################################
# Get file name from path.
#
# Arguments:
#   path
#
# Outputs:
#   file name
#######################################
function file_name() {
  basename -- "${1}"
}

#######################################
# Check if directory is empty.
#
# Arguments:
#   Directory
#
# Returns:
#   0 if directory is not empty.
#   1 if directory is empty.
#######################################
function is_directory_empty() {
  [ "$(ls -A "${1}")" ] && return 1 || return 0
}

#######################################
# Check if path for file is remote
#
# Arguments:
#   file
#
# Returns:
#   0 if file is remote.
#   1 if file is not remote.
#######################################
function is_file_remote() {
  local protocol
  protocol="$(git::protocol "$1")"

  [[ -n ${protocol} ]] && return 0 || return 1
}
