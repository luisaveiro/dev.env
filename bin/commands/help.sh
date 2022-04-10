# shellcheck shell=bash
#
# DEV.env help shell command

#######################################
# Display help section
#
# Arguments:
#   --project_dir
#   --tagline
#   --package
#######################################
function command::help() {
  local arguments_list=("project_dir" "tagline" "package")
  local packages=() project_dir tagline
  tagline="Kick start your development environment while making a cup of coffee"

  local commands=(
    "help"
    "self-update"
  )

  local descriptions=(
    "List of all available commands"
    "Update DEV.env to the latest version"
  )

  while [ $# -gt 0 ]; do
    if [[ $1 == *"--"* && $1 == *"="* ]]; then
      local argument="${1/--/}"
      IFS='=' read -ra parameter <<< "${argument}"

      if [[ "${arguments_list[*]}" =~ ${parameter[0]} ]]; then
        if [[ $1 == *"--package="* ]]; then
          if [ "${parameter[1]}" != "" ]; then
            packages+=("${parameter[1]}")
          fi
        else
          declare "${parameter[0]}"="${parameter[1]}"
        fi
      fi
    fi

    shift
  done

  output "$(ansi --bold --white DEV.env)" \
    "$(git::latest_tag --dir="${project_dir}")"

  output "$(ansi --italic "${tagline}")"

  output --newline=top "- Star or contribute to DEV.env:"
  echo "  $(ansi --bold --white https://github.com/luisaveiro/dev.env)"

  help::boilerplate
  help::command_max_length 17
  help::command_max_tabs 2

  for index in "${!commands[@]}"
  do
    help::add_command \
      --command="${commands[index]}" \
      --description="${descriptions[index]}"
  done

  help::display_commands

  for package in "${packages[@]}"
  do
    package::load "${package}/help.sh"

    "${package}::help"
  done
}
