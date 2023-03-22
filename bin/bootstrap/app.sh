# shellcheck shell=bash
#
# DEV.env application.

#######################################
# The main function for DEV.env
# application.
#
# Globals:
#   APP_NAME
#
# Arguments:
#   User input
#
# Outputs:
#   Writes error messages to stdout.
#
# Returns:
#   1 if the OS is not supported or
#     dependencies are not installed.
#######################################
function main() {
  if ! os::is_supported; then
    console::error --margin-top \
      "Your OS is not supported. $(ansi --bold --white "${APP_NAME}")" \
      "supports macOS, Linux, and Windows (WSL2)."

    exit 1
  fi

  if ! os::has_installed git; then
    console::error --margin-top --margin-bottom "Git is not installed!"

    # Git download URL.
    local url="https://git-scm.com"
    readonly url

    console::output \
      "$(ansi --bold --white "${APP_NAME}") requires Git to update to the" \
      "latest version. Please installed Git via" \
      "$(ansi --bold --white --underline "${url}")."

    exit 1
  fi

  devenv::console "$@"
}
