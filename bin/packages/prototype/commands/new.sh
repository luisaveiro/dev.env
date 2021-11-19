# shellcheck shell=bash
#
# Prototype package new command.

#######################################
# Start new prototype project.
#
# Arguments:
#   --sample_dir
#######################################
function prototype::new() {
  local arguments_list=("sample_dir")
  local sample_dir sample=$* samples input

  while [ $# -gt 0 ]; do
    if [[ $1 == *"--"* && $1 == *"="* ]]; then
      local argument="${1/--/}"
      IFS='=' read -ra parameter <<< "${argument}"

      if [[ "${arguments_list[*]}" =~ ${parameter[0]} ]]; then
        sample="${sample/--${argument}/}"
        declare "${parameter[0]}"="${parameter[1]}"
      fi
    fi

    shift
  done

  # Strip out whitespaces
  sample="${sample//[[:blank:]]/}"

  samples::check --sample_dir="${sample_dir}"

  samples="$(samples::list --sample_dir="${sample_dir}/*")"
  IFS=' ' read -ra samples <<< "${samples}"

  if [[ -z $sample ]]; then
    samples::table --sample_dir="${sample_dir}"

    info "You can create a prototype skeleton from the following samples." \
      "You can select a sample by referencing the" \
      "$(ansi --white --bold Sample Name) or $(ansi --white --bold Number)."

    question --newline=top "$(ansi --white --bold Which sample would you like to use?)"

    # Read the answer (use /dev/tty in case stdin is redirected from somewhere else)
    read -r input </dev/tty

    if [[ $input =~ ^[0-9]+$ ]]; then
      input="$((input - 1))"
      sample="${samples[$input]}"
    else
      sample="${input}"
    fi
  fi

  output --newline=top --newline=bottom \
    "$(ansi --white SELECTED:) $(ansi --bold --white "${sample}")"

  info "[1/2] Validating your option ..."

  if [[ ! "${samples[*]}" =~ ${sample} ]] || ! directory_exists "${sample_dir}/${sample}"
  then
    info --overwrite --newline=bottom \
      "[1/2] Validating your option $(ansi --bold --red "[FAILED]")"

    error "Your option $(ansi --bold --white "${sample}") is not a valid sample."

    exit 1
  fi

  info --overwrite "[1/2] Validating your option" \
    "$(ansi --bold --white "[OK]")"

  info "[2/2] Copying $(ansi --bold --white "${sample}")" \
    "$(ansi --bold --white "[PROCESSING]")"

  if ! is_directory_empty "$(pwd)"; then
    info --overwrite --newline=bottom \
      "[2/2] Copying $(ansi --bold --white "${sample}")" \
      "$(ansi --bold --red "[FAILED]")"

    warning "Directory $(ansi --bold --white "$(basename -- "$(pwd)")") " \
      "is not empty."

    exit 1
  fi

  cp -a "${sample_dir}/${sample}/." "."

  info --overwrite "[2/2] Copying $(ansi --bold --white "${sample}")" \
    "$(ansi --bold --green "[COMPLETED]")"
}
