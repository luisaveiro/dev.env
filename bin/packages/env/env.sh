# shellcheck shell=bash
#
# DEV.env package.

readonly ENV_DIR="${PACKAGES_DIR}/ENV"

readonly ENV_DEPENDENCIES=(
  "${ENV_DIR}/functions/functions"
  "${ENV_DIR}/commands/commands"
)

for dependency in "${ENV_DEPENDENCIES[@]}"
do
  # shellcheck source=/dev/null
  source "${dependency}.sh"
done

#######################################
# DEV.env package shell script.
#
# Globals:
#   SETUP_DIR
#
# Arguments:
#   User input
#
# Returns:
#   1 if user input is not valid.
#######################################
function package::env() {
  for arg in "$@"; do
    shift
    case "$arg" in
      config)
        env::config --setup_dir="${SETUP_DIR}" "$@"
        break;;
      setup)
        env::setup --setup_dir="${SETUP_DIR}" "$@"
        break;;
      *)
        error "Command $(ansi --bold --white "env:${arg}")" \
          "is not supported."

        exit 1;;
    esac
  done
}
