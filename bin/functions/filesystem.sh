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
# Get file extension.
#
# Arguments:
#   file
#
# Outputs:
#   git hostname
#######################################
function file_extension() {
  local file_name
  file_name="$(file_name "${1}")"

  echo "${file_name#*.}"
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
  local regex="^(http|https|git)(:\/\/|@)"

  [[ $1 =~ ${regex} ]] && return 0 || return 1
}

#######################################
# Create a Symlink
#
# Arguments:
#   --original
#   --link
#######################################
function symlink() {
  local arguments_list=("original" "link")
  local original link

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

  ln -s "${original}" "${link}"
}
