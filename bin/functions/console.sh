# shellcheck shell=bash
#
# Internal console functions.

#######################################
# Get user input confirmation.
#
# Arguments:
#   Message
#   Default input
#
# Outputs:
#   Writes message to stdout.
#
# Returns:
#   1 if user input is no.
#   0 if user input is yes.
#######################################
function ask() {
  local prompt default reply

  case "${2:-}" in
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
    echo -n "$1 [$prompt] "

    # Read the answer (use /dev/tty in case stdin is redirected from somewhere else)
    read -r reply </dev/tty

    if [[ -z $reply ]]; then
      reply=$default
    fi

    case "$reply" in
      Y*|y*) return 0;;
      N*|n*) return 1;;
    esac
  done
}

#######################################
# Output debug message to terminal.
#
# Arguments:
#   --overwrite
#   --newline
#   Message
#######################################
function debug() {
  output "$(ansi --green DEBUG:)" "$@"
}

#######################################
# Output error message to terminal.
#
# Arguments:
#   --overwrite
#   --newline
#   Message
#######################################
function error() {
  output "$(ansi --red ERROR:)" "$@"
}

#######################################
# Output info message to terminal.
#
# Arguments:
#   --overwrite
#   --newline
#   Message
#######################################
function info() {
  output "$(ansi --color=33 INFO:)" "$@"
}

#######################################
# Output a new line to terminal.
#######################################
function newline() {
  echo -e ""
}

#######################################
# Output message to terminal.
#
# Arguments:
#   --overwrite
#   --newline
#   --no-trailing
#   Message
#
# Outputs:
#   Writes message to stdout.
#######################################
function output() {
  local text overwrite newlines=() messages trailing="yes"

  messages=$*

  while [ $# -gt 0 ]; do
    if [[ $1 == *"--overwrite"* ]]; then
      overwrite="\r\033[1A\033[0K"
      messages="${messages/--overwrite/}"
    fi

    if [[ $1 == *"--newline="* ]]; then
      local argument="${1/--/}"
      messages="${messages/--${argument}/}"

      IFS='=' read -ra parameter <<< "${argument}"
      newlines+=("${parameter[1]}")
    fi

    if [[ $1 == *"--no-trailing"* ]]; then
      trailing="no"
      messages="${messages/--no-trailing/}"
    fi

    shift
  done

  IFS=' ' read -ra messages <<< "${messages}"
  text="${messages[*]}"

  if [[ ${newlines[*]} =~ "top" && -n $overwrite ]]; then
    echo -e "${overwrite}"
  elif [[ ${newlines[*]} =~ "top" ]]; then
    newline
  elif [[  -n $overwrite ]]; then
    text="${overwrite}${text}"
  fi

  if [[ "${trailing}" == "yes" ]]; then
    echo -e "${text}"
  else
    echo -e -n "${text} "
  fi

  if [[ ${newlines[*]} =~ "bottom" ]]; then
    newline
  fi
}

#######################################
# Output question message to terminal.
#
# Arguments:
#   --overwrite
#   --newline
#   Message
#######################################
function question() {
  output --no-trailing "$(ansi --bold --color=11 QUESTION:)" "$@"
}

#######################################
# Output warning message to terminal.
#
# Arguments:
#   --overwrite
#   --newline
#   Message
#######################################
function warning() {
  output "$(ansi --yellow WARNING:)" "$@"
}
