# shellcheck shell=bash
#
# Prototype package samples functions.

SAMPLE_GIT="https://github.com/docker/awesome-compose.git"

#######################################
# Clone or update Awesome Docker Compose samples
#
# Global:
#   SAMPLE_GIT
#
# Arguments:
#   --sample_dir
#######################################
function samples::check() {
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

  if ! directory_exists "${sample_dir}"; then
    info "Directory $(ansi --bold --white "$(basename -- "${sample_dir}")")" \
      "doesn't exists."

    info --newline=bottom \
      "Creating $(ansi --bold --white "$(basename -- "${sample_dir}")")" \
      "directory..."

    mkdir "${sample_dir}"
  fi

  if ! directory_exists "${sample_dir}/.git"; then
    repository::clone \
      --dir="${sample_dir}" \
      --git="${SAMPLE_GIT}"
  else
    repository::update \
      --dir="${sample_dir}"
  fi
}

#######################################
# list Awesome Docker Compose samples in a table
#
# Arguments:
#   --sample_dir
#######################################
function samples::list() {
  local arguments_list=("sample_dir")
  local sample_dir samples=()

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

  for dir in ${sample_dir}
  do
    if [[ ! -d "${dir}" ]]; then
      continue
    fi

    samples+=(
      "$(file_name "${dir}")"
    )
  done

  echo "${samples[@]}"
}

#######################################
# list Awesome Docker Compose samples in a table
#
# Arguments:
#   --sample_dir
#######################################
function samples::table() {
  local arguments_list=("sample_dir")
  local sample_dir samples sample_records=()

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

  samples="$(samples::list --sample_dir="${sample_dir}/*")"

  IFS=' ' read -ra samples <<< "${samples}"

  for sample in "${samples[@]}"
  do
    sample_records+=(
      "${sample}"
      "${sample//-/, }"
      "https://github.com/docker/awesome-compose/tree/master/${sample}"
    )
  done

  total_files="$((${#sample_records[@]}/3))"

  newline

  # shellcheck disable=SC2059
  printf "$(ansi --white --bold %-10s) $(ansi --green --bold %3d) \n" \
    "- Total Samples" "${total_files}"

  newline

  table::row_numbers true
  table::header_style "--green"
  table::header "Sample Name" "Tech Stack" "ReadMe URLs"
  table::records "${sample_records[@]}"
  table::display

  info --newline=top --newline=bottom "To view the README URLS," \
    "$(ansi --white --bold "hold Ctrl or Command key for MacOS")" \
    "while clicking on the link to launch the URL in your default browser."
}
