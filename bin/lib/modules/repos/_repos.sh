# shellcheck shell=bash
#
# Load DEV.env Repos module.

#######################################
# Define Repos Module Name
#######################################

export MODULE_NAME="repos"

#######################################
# Define Repos Module Directory
#######################################

readonly REPOS_MODULE_DIR="${MODULE_DIR}/${MODULE_NAME}"

#######################################
# Define Repos Dependencies
#######################################

readonly REPOS_DEPENDENCIES=(
  "commands"
  "services"
)

#######################################
# Load Repos Dependencies
#######################################

for DEPENDENCY in "${REPOS_DEPENDENCIES[@]}"; do
  # shellcheck source=/dev/null
  source "${REPOS_MODULE_DIR}/${DEPENDENCY}/_${DEPENDENCY}.sh"
done
