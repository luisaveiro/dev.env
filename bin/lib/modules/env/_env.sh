# shellcheck shell=bash
#
# Load DEV.env ENV module.

#######################################
# Define ENV Module Name
#######################################

export MODULE_NAME="env"

#######################################
# Define ENV Module Directory
#######################################

readonly ENV_MODULE_DIR="${MODULE_DIR}/${MODULE_NAME}"

#######################################
# Define ENV Dependencies
#######################################

readonly ENV_DEPENDENCIES=(
)

#######################################
# Load ENV Dependencies
#######################################

for DEPENDENCY in "${ENV_DEPENDENCIES[@]}"; do
  # shellcheck source=/dev/null
  source "${ENV_MODULE_DIR}/${DEPENDENCY}/_${DEPENDENCY}.sh"
done
