# shellcheck shell=bash
#
# Repos package commands.

readonly REPOS_COMMANDS_DIR="${REPOS_DIR}/commands"

readonly REPOS_COMMANDS=(
  "config"
  "publish"
  "setup"
  "status"
)

for repos_command in "${REPOS_COMMANDS[@]}"
do
  # shellcheck source=/dev/null
  source "${REPOS_COMMANDS_DIR}/${repos_command}.sh"
done
