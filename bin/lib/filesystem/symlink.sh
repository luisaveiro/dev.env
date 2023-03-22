# shellcheck shell=bash
#
# DEV.env internal filesystem symlink functions.

#######################################
# Create a Symbolic Link.
#
# Arguments:
#   --original
#   --link
#######################################
function symlink::create() {
  local arguments_list=("link" "original")
  local link
  local original

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

  # If path is working directory, rebuild full path.
  original_file_path="$(filesystem::file_path "${original}")"
  original_file_name="$(filesystem::file_name "${original}")"

  original="${original_file_path}/${original_file_name}"

  # If path is working directory, rebuild full path.
  link_file_path="$(filesystem::file_path "${link}")"
  link_file_name="$(filesystem::file_name "${link}")"

  link="${link_file_path}/${link_file_name}"

  ln -s "${original}" "${link}"
}

#######################################
# Remove the Symbolic Link.
#
# Arguments:
#   link
#######################################
function symlink::remove() {
  unlink "${1}"
}

#######################################
# Check if the path is a Symbolic Link.
#
# Arguments:
#   link
#
# Returns:
#   0 if the path is a symbolic link.
#   1 if the path is not a symbolic
#     link.
#######################################
function symlink::is_symlink() {
  [[ -L "${1}" ]] && return 0 || return 1
}

#######################################
# Check if the Symbolic Link is valid.
#
# Arguments:
#   link
#
# Returns:
#   0 if the symbolic link is valid.
#   1 if the symbolic link isn't valid.
#######################################
function symlink::is_valid() {
  [[ -e "${1}" ]] && return 0 || return 1
}

#######################################
# Get the target file for the Symbolic
# Link.
#
# Arguments:
#   link
#
# Outputs:
#   The file name including path.
#######################################
function symlink::target() {
  readlink -f "${1}"
}
