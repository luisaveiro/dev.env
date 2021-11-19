# shellcheck shell=bash
#
# Prototype package commands.

readonly PROTOTYPE_COMMANDS_DIR="${PROTOTYPE_DIR}/commands"

readonly PROTOTYPE_COMMANDS=(
  "new"
  "samples"
)

for prototype_command in "${PROTOTYPE_COMMANDS[@]}"
do
  # shellcheck source=/dev/null
  source "${PROTOTYPE_COMMANDS_DIR}/${prototype_command}.sh"
done
