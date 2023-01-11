# shellcheck shell=bash
#
# DEV.env Command Line Interface (CLI).

#######################################
# The DEV.env CLI.
#
# Globals:
#   APP_COMMAND
#
# Arguments:
#   User input
#
# Outputs:
#   Writes messaging to stdout.
#
# Returns:
#   1 if the command is not supported.
#######################################
function devenv::console() {
  if [ $# == 0 ]; then
    command::usage

    exit 0
  fi

  for argument in "$@"; do
    shift
    case "${argument}" in
      -v|--version)
        command::version
        break;;
      -h|--help)
        command::usage
        break;;
      *)
        local cli_command="command::${argument//-/_}"

        if [[ $( type -t "${cli_command}" ) != function ]]; then
          console::error --margin-top --margin-bottom \
            "Command $(ansi --bold --white "${argument}" ) is not supported."

          console::output \
            "To view a list of all available commands use the following:" \
            "$(ansi --bold --white "${APP_COMMAND} --help")"

          exit 1
        fi

        # Execute the DEV.env command.
        "${cli_command}" "$@"

        break;;
    esac
  done
}
