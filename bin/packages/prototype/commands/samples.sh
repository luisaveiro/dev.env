# shellcheck shell=bash
#
# Prototype package samples command.

#######################################
# List Docker Compose samples.
#
# Arguments:
#   --sample_dir
#######################################
function prototype::samples() {
  local arguments_list=("sample_dir")
  local sample_dir

  while [ $# -gt 0 ]; do
    if [[ $1 == *"--"* && $1 == *"="* ]]; then
      local argument="${1/--/}"
      IFS='=' read -ra parameter <<< "${argument}"

      if [[ "${arguments_list[*]}" =~ ${parameter[0]} ]]; then
        declare "${parameter[0]}"="${parameter[1]}"
      fi
    fi

    shift
  done

  samples::check --sample_dir="${sample_dir}"
  samples::table --sample_dir="${sample_dir}"

  info "Use the following command to create a prototype" \
    "skeleton from the following samples" \
    "$(ansi --bold --white prototype:new "<sample-name>")"
}
