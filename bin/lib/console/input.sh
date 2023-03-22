# shellcheck shell=bash
#
# DEV.env internal console interaction functions.

#######################################
# Get the user input confirmation
# from the terminal.
#
# Arguments:
#   --default
#   --message
#
# Outputs:
#   Writes the message to stdout.
#
# Returns:
#   0 if the user input is yes.
#   1 if the user input is no.
#######################################
function console::ask() {
  local arguments_list=("default" "message")
  local default
  local message
  local prompt
  local reply

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

  case "${default}" in
    'Y')
      prompt='Y/n'
      default='Y';;
    'N')
      prompt='y/N'
      default='N';;
    *)
      prompt='y/n'
      default='';;
  esac

  while true; do
    console::question "$(ansi --white --bold "${message}") [${prompt}]"
    reply="$(console::input --default="${default}")"

    case "${reply}" in
      Y*|y*) return 0;;
      N*|n*) return 1;;
    esac
  done
}

#######################################
# Get the user input from the
# terminal.
#
# Arguments:
#   --default
#
# Outputs:
#   Writes the message to stdout.
#######################################
function console::input() {
  local default
  local input

  while [ $# -gt 0 ]; do
    if [[ $1 == *"--default="* ]]; then
      local argument="${1/--/}"
      IFS='=' read -ra parameter <<< "${argument}"

      declare "${parameter[0]}"="${parameter[1]}"
    fi

    shift
  done

  # Read the user input.
  # Use /dev/tty in case stdin is redirected from somewhere else.
  read -r input </dev/tty

  if [[ -z "${input}" ]]; then
    input="${default}"
  fi

  console::output "${input}"
}
