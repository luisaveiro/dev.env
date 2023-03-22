# shellcheck shell=bash
#
# Load DEV.env Repos module commands.

#######################################
# Define Repos Module Commands
#######################################

readonly REPOS_COMMANDS=(
  "add_config"
  "list"
  "publish"
  "setup"
  "status"
  "usage"
)

#######################################
# Load Repos Module Commands
#######################################

for COMMAND in "${REPOS_COMMANDS[@]}"; do
  # shellcheck source=/dev/null
  source "${REPOS_MODULE_DIR}/commands/${COMMAND}.sh"
done
