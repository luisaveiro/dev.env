# shellcheck shell=bash
#
# Load DEV.env support helpers.

#######################################
# Define Support Helpers
#######################################

readonly SUPPORT_HELPERS=(
  "explain"
  "help"
  "module"
)

#######################################
# Load Support Helpers
#######################################

for SUPPORT_HELPER in "${SUPPORT_HELPERS[@]}"; do
  # shellcheck source=/dev/null
  source "${LIB_DIR}/support/${SUPPORT_HELPER}.sh"
done
