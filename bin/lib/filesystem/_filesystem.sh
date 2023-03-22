# shellcheck shell=bash
#
# Load DEV.env filesystem dependencies.

#######################################
# Define Filesystem Dependencies
#######################################

readonly FILESYSTEM_DEPENDENCIES=(
  "directories"
  "files"
  "symlink"
)

#######################################
# Load Filesystem Dependencies
#######################################

for FILESYSTEM in "${FILESYSTEM_DEPENDENCIES[@]}"; do
  # shellcheck source=/dev/null
  source "${LIB_DIR}/filesystem/${FILESYSTEM}.sh"
done
