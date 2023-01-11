# shellcheck shell=bash
#
# DEV.env docs command.

#######################################
# Display the DEV.env docs
# information.
#
# Globals:
#   APP_NAME
#   GIT_REPOSITORY
#   PROJECT_DIR
#
# Outputs:
#   Writes docs information to stdout.
#######################################
function command::docs() {
  local readme_url
  local version

  version="$(git::active_branch --dir="${PROJECT_DIR}")"
  readme_url="${GIT_REPOSITORY}/blob/${version}/README.md"

  console::output --margin-bottom "${APP_NAME} documentation:"

  console::output "$(ansi --bold --white "- Readme")" "${readme_url}"

  console::info --margin-top \
    "Opening the Readme (${version}) to: $(ansi --bold --white "${readme_url}")"

  browser::open "${readme_url}"
}

#######################################
# Display helpful information for
# the docs command.
#
# Globals:
#   APP_COMMAND
#   APP_NAME
#   GIT_REPOSITORY
#
# Outputs:
#   Writes helpful information to
#   stdout.
#######################################
function explain::docs() {
  local helpful_tips=(
    "To open the docs URL in your default browser:"
    "${APP_COMMAND} docs"
  )

  explain::display_description \
    "Open ${APP_NAME} documentation in your default browser."

  explain::display_usage "docs"

  explain::display_helpful_tips "${helpful_tips[@]}"

  explain::display_more_information "${GIT_REPOSITORY}#docs-command"
}
