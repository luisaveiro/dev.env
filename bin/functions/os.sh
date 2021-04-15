# shellcheck shell=bash
#
# Internal os functions.

#######################################
# Check if operating system is either macOS or Linux.
#
# Returns:
#   1 if OS is not supported.
#######################################
function is_operating_system_supported() {
  local unameout machine

  unameout="$(uname -s)"

  case $unameout in
    Linux*)
      machine=Linux;;
    Darwin*)
      machine=mac;;
    *)
      machine="UNKNOWN";;
  esac

  if [ $machine == "UNKNOWN" ]; then
    error "Unsupported OS [$(ansi --bold --white "${unameout}")]." \
      "$(ansi --italic --bold --white DEV.env) supports macOS and Linux."

    exit 1
  fi
}
