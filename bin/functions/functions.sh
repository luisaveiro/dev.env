# shellcheck shell=bash
#
# Functions manager.

readonly FUNCTIONS_DIR="${CURRENT_DIR}/functions"

readonly FUNCTIONS=(
  "console"
  "filesystem"
  "os"
)

for function in "${FUNCTIONS[@]}"
do
  # shellcheck source=/dev/null
  source "${FUNCTIONS_DIR}/${function}.sh"
done
