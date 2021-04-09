# shellcheck shell=bash
#
# Repos package functions.

readonly REPOS_FUNCTIONS_DIR="${REPOS_DIR}/functions"

readonly REPOS_FUNCTIONS=(
  "repository"
)

for repos_function in "${REPOS_FUNCTIONS[@]}"
do
  # shellcheck source=/dev/null
  source "${REPOS_FUNCTIONS_DIR}/${repos_function}.sh"
done
