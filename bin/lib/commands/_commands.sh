# shellcheck shell=bash
#
# Load DEV.env commands.

#######################################
# Define Commands
#######################################

readonly COMMANDS=(
  "about"
  "docs"
  "help"
  "self_update"
  "usage"
  "version"
)

#######################################
# Load Commands
#######################################

for COMMAND in "${COMMANDS[@]}"; do
  # shellcheck source=/dev/null
  source "${LIB_DIR}/commands/${COMMAND}.sh"
done
