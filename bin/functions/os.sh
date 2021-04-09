# shellcheck shell=bash
#
# Internal os functions.

#######################################
# Check if operating system is either macOS.
#
# Returns:
#   1 if OS is not supported.
#######################################
function is_operating_system_supported() {
  local unameout machine

  unameout="$(uname -s)"

  case $unameout in
    Darwin*)
      machine=mac;;
    *)
      machine="UNKNOWN";;
  esac

  if [ $machine == "UNKNOWN" ]; then
    error "Unsupported OS [$(ansi --bold --white "${unameout}")]." \
      "$(ansi --italic --bold --white DEV.env) supports macOS."

    exit 1
  fi
}
