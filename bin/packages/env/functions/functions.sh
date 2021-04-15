# shellcheck shell=bash
#
# DEV.env package functions.

readonly ENV_FUNCTIONS_DIR="${ENV_DIR}/functions"

readonly ENV_FUNCTIONS=(
  "configuration"
)

for env_function in "${ENV_FUNCTIONS[@]}"
do
  # shellcheck source=/dev/null
  source "${ENV_FUNCTIONS_DIR}/${env_function}.sh"
done
