# shellcheck shell=bash
#
# Load DEV.env Prototype module.

#######################################
# Define Prototype Module Name
#######################################

export MODULE_NAME="prototype"

#######################################
# Define Prototype Module Directory
#######################################

readonly PROTOTYPE_MODULE_DIR="${MODULE_DIR}/${MODULE_NAME}"

#######################################
# Define Prototype Dependencies
#######################################

readonly PROTOTYPE_DEPENDENCIES=(
)

#######################################
# Load Prototype Dependencies
#######################################

for DEPENDENCY in "${PROTOTYPE_DEPENDENCIES[@]}"; do
  # shellcheck source=/dev/null
  source "${PROTOTYPE_MODULE_DIR}/${DEPENDENCY}/_${DEPENDENCY}.sh"
done
