# shellcheck shell=bash
#
# Prototype package functions.

readonly PROTOTYPE_FUNCTIONS_DIR="${PROTOTYPE_DIR}/functions"

readonly PROTOTYPE_FUNCTIONS=(
  "repository"
  "samples"
)

for prototype_function in "${PROTOTYPE_FUNCTIONS[@]}"
do
  # shellcheck source=/dev/null
  source "${PROTOTYPE_FUNCTIONS_DIR}/${prototype_function}.sh"
done
