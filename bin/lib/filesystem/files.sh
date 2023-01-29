# shellcheck shell=bash
#
# DEV.env internal filesystem files functions.

#######################################
# Check if the file exists.
#
# Arguments:
#   File
#
# Returns:
#   0 if the file exists.
#   1 if the file does not exsits.
#######################################
function filesystem::does_file_exists() {
  [ -f "${1}" ] && return 0 || return 1
}

#######################################
# Get the file extension for the file.
#
# Arguments:
#   file
#
# Outputs:
#   File extension.
#######################################
function filesystem::file_extension() {
  local file_name="${1}"

  if [[ "${file_name}" == *"."* ]]; then
    file_name="$(filesystem::file_name "${file_name}")"
    console::output "${file_name#*.}"
  else
    console::output ""
  fi
}

#######################################
# Get the file name from the path.
#
# Arguments:
#   path
#
# Outputs:
#   The file name.
#######################################
function filesystem::file_name() {
  basename -- "${1}"
}

#######################################
# Get the file path from the file.
#
# Arguments:
#   path
#
# Outputs:
#   The file name.
#######################################
function filesystem::file_path() {
  local file_path

  file_path="$(dirname "${1}")"

  if [[ "${file_path}" == "." ]]; then
    file_path="$(pwd)"
  fi

  console::output "${file_path}"
}

#######################################
# Check if the file is a remote file.
#
# Arguments:
#   file
#
# Returns:
#   0 if file is remote.
#   1 if file is not remote.
#######################################
function filesystem::is_remote_file() {
  [[ $1 =~ ^(http|https|git)(:\/\/|@) ]] && return 0 || return 1
}
