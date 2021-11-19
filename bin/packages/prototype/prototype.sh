# shellcheck shell=bash
#
# Prototype package.

readonly PROTOTYPE_DIR="${PACKAGES_DIR}/prototype"

readonly PROTOTYPE_DEPENDENCIES=(
  "${PACKAGES_DIR}/table/table"
  "${PROTOTYPE_DIR}/functions/functions"
  "${PROTOTYPE_DIR}/commands/commands"
)

for dependency in "${PROTOTYPE_DEPENDENCIES[@]}"
do
  # shellcheck source=/dev/null
  source "${dependency}.sh"
done

#######################################
# Prototype package shell script.
#
# Globals:
#   SAMPLE_DIR
#
# Arguments:
#   User input
#
# Returns:
#   1 if user input is not valid.
#######################################
function package::prototype() {
  # Check if docker is running.
  # Warning message

  for arg in "$@"; do
    shift
    case "$arg" in
      new)
        prototype::new --sample_dir="${SAMPLE_DIR}" "$@"
        break;;
      samples)
        prototype::samples --sample_dir="${SAMPLE_DIR}"
        break;;
      *)
        error "Command $(ansi --bold --white "prototype:${arg}")" \
          "is not supported."

        exit 1;;
    esac
  done
}
