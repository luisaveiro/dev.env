# shellcheck shell=bash
#
# DEV.env self update command.

#######################################
# Update DEV.env to the latest
# version.
#
# Globals:
#   APP_COMMAND
#   APP_NAME
#   PROJECT_DIR
#
# Outputs:
#   Writes messages to stdout.
#######################################
function command::self_update() {
  local latest_tag
  local question="Do you want to update ${APP_NAME} to the latest version?"

  if ! os::has_installed git; then
    console::error --margin-top --margin-bottom "Git is not installed!"

    # Git download URL.
    local url="https://git-scm.com"
    readonly url

    console::output \
      "$(ansi --bold --white "${APP_NAME}") requires Git to update to the" \
      "latest version. Please installed Git via" \
      "$(ansi --bold --white --underline "${url}")."

    exit 1
  fi

  if ! console::ask --message="${question}" --default=Y; then
    exit 1
  fi

  git::fetch --dir="${PROJECT_DIR}"

  latest_tag="$(git::latest_tag --dir="${PROJECT_DIR}")"

  console::info \
    "[1/1] Updating $(ansi --bold --white "${APP_NAME}")" \
    "to $(ansi --bold --white "${latest_tag}") ..."

  progressbar::start
  progressbar::half
  progressbar::finish --clear

  console::info --overwrite \
    "[1/1] Updating $(ansi --bold --white "${APP_NAME}")" \
    "to $(ansi --bold --white "${latest_tag}") $(ansi --bold --white "[OK]")"

  git::checkout --dir="${PROJECT_DIR}" --branch="${latest_tag}"
}

#######################################
# Display helpful information for
# the self-update command.
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
function explain::self_update() {
  local helpful_tips=(
    "Update ${APP_NAME} to the latest version:"
    "${APP_COMMAND} self-update"
  )

  explain::display_description \
    "Update ${APP_NAME} to the latest version."

  explain::display_usage "self-update"

  explain::display_helpful_tips "${helpful_tips[@]}"

  explain::display_more_information "${GIT_REPOSITORY}#self-update-command"
}
