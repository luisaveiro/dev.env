# shellcheck shell=bash
#
# DEV.env DotEnv function.

#######################################
# Retrieve the environment variable.
#
# Arguments:
#   --file
#   --default
#   variable
#
# Outputs:
#   Variable value or default value.
#######################################
function dotenv::get() {
  local arguments_list=("file" "default")
  local default
  local file=".env"
  local variable=$*

  while [ $# -gt 0 ]; do
    if [[ $1 == *"--"* && $1 == *"="* ]]; then
      local argument="${1/--/}"
      IFS='=' read -ra parameter <<< "${argument}"

      if [[ "${arguments_list[*]}" =~ ${parameter[0]} ]]; then
        variable="${variable/--${argument}/}"
        declare "${parameter[0]}"="${parameter[1]}"
      fi
    fi

    shift
  done

  if [ -f "${file}" ]; then
    # Strip out whitespaces
    variable="${variable//[[:blank:]]/}"

    # shellcheck source=/dev/null
    source "${file}"

    if [[ -z "${!variable}" ]]; then
      echo "${default}"
    else
      # Replace single quotes for double qoutes to support JSON variables.
      echo "${!variable//\'/\"/}"
    fi
  else
    echo "${default}"
  fi
}
