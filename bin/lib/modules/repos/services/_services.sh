# shellcheck shell=bash
#
# Load DEV.env Repos module services.

#######################################
# Define Repos Module Services
#######################################

readonly REPOS_SERVICES=(
  "configuration"
)

#######################################
# Load Repos Module Services
#######################################

for SERVICE in "${REPOS_SERVICES[@]}"; do
  # shellcheck source=/dev/null
  source "${REPOS_MODULE_DIR}/services/${SERVICE}.sh"
done
