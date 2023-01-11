# shellcheck shell=bash
#
# Load DEV.env core dependencies.

#######################################
# Define Core Dependencies
#######################################

readonly CORE_DEPENDENCIES=(
  "devenv"
)

#######################################
# Load Core Dependencies
#######################################

for CORE in "${CORE_DEPENDENCIES[@]}"; do
  # shellcheck source=/dev/null
  source "${LIB_DIR}/core/${CORE}.sh"
done
