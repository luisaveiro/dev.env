# shellcheck shell=bash
#
# DEV.env self update shell command

#######################################
# Update DEV.env to the latest version
#
# Arguments:
#   --project_dir
#######################################
function command::self_update() {
  local project_dir latest_tag

  while [ $# -gt 0 ]; do
    if [[ $1 == *"--project_dir="* ]]; then
      local argument="${1/--/}"

      IFS='=' read -ra parameter <<< "${argument}"

      declare "${parameter[0]}"="${parameter[1]}"
    fi

    shift
  done

  git::fetch --dir="${project_dir}"

  latest_tag="$(git::latest_tag --dir="${project_dir}")"

  info "[1/1] Updating $(ansi --bold --white DEV.env)" \
    "to $(ansi --bold --white "${latest_tag}") ..."

  progressbar::start
  progressbar::half
  progressbar::finish --clear

  info --overwrite "[1/1] Updating $(ansi --bold --white DEV.env)" \
    "to $(ansi --bold --white "${latest_tag}") $(ansi --bold --white "[OK]")"

  git::checkout --dir="${project_dir}" --branch="${latest_tag}"
}
