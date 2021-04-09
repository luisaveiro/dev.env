# shellcheck shell=bash
#
# DEV.env package commands.

readonly ENV_COMMANDS_DIR="${ENV_DIR}/commands"

readonly ENV_COMMANDS=(
  "config"
  "setup"
)

for env_command in "${ENV_COMMANDS[@]}"
do
  # shellcheck source=/dev/null
  source "${ENV_COMMANDS_DIR}/${env_command}.sh"
done
