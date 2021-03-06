# shellcheck shell=bash
#
# Available shell commands.

readonly COMMANDS_DIR="${CURRENT_DIR}/commands"

readonly COMMANDS=(
  "help"
  "self_update"
)

for command in "${COMMANDS[@]}"
do
  # shellcheck source=/dev/null
  source "${COMMANDS_DIR}/${command}.sh"
done
