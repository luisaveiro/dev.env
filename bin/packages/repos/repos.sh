# shellcheck shell=bash
#
# Repos package.

readonly REPOS_DIR="${PACKAGES_DIR}/repos"

readonly REPOS_DEPENDENCIES=(
  "${PACKAGES_DIR}/table/table"
  "${PACKAGES_DIR}/yaml/yaml"
  "${REPOS_DIR}/commands/commands"
  "${REPOS_DIR}/functions/functions"
)

for dependency in "${REPOS_DEPENDENCIES[@]}"
do
  # shellcheck source=/dev/null
  source "${dependency}.sh"
done

#######################################
# Repos main shell script.
#
# Globals:
#   TEMPLATES_DIR
#
# Arguments:
#   User input
#
# Returns:
#   1 if user input is not valid.
#######################################
function package::repos() {
  for arg in "$@"; do
    shift
    case "$arg" in
      config)
        repos::config --template_dir="${TEMPLATES_DIR}" "$@"
        break;;
      publish)
        repos::publish --template_dir="${TEMPLATES_DIR}" "$1"
        break;;
      setup)
        repos::setup "$@"
        break;;
      status)
        repos::status
        break;;
      *)
        error "Command $(ansi --bold --white "repos:${arg}")" \
          "is not supported."

        exit 1;;
    esac
  done
}
