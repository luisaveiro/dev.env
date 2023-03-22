# shellcheck shell=bash
# shellcheck disable=SC2059
#
# DEV.env internal table functions.

#######################################
# Add row numbers to the table.
#
# Globals:
#   TABLE_HEADERS
#   TABLE_RECORDS
#######################################
function table::configure_row_numbers() {
  local total_columns="${#TABLE_HEADERS[@]}"
  local total_records="${#TABLE_RECORDS[@]}"
  local total_rows=$((total_records / total_columns))
  local temporary_table_records=()

  # loop through records and add row number
  for (( row_index=0; row_index<total_rows; row_index++ )); do
    if [[ ${row_index} == 0 ]]; then
      array_column_start="0"
      array_column_end="${total_columns}"
    else
      array_column_end=$(( (row_index + 1) * total_columns ))
      array_column_start=$((array_column_end - total_columns))
    fi

    local row_records=(
      "$((row_index + 1))"
      "${TABLE_RECORDS[@]:${array_column_start}:${total_columns}}"
    )

    temporary_table_records+=("${row_records[@]}")
  done

  TABLE_HEADERS=("#" "${TABLE_HEADERS[@]}")
  TABLE_RECORDS=("${temporary_table_records[@]}")
}

#######################################
# Display the table.
#
# Globals:
#   TABLE_HEADERS
#   TABLE_HEADERS_STYLE
#   TABLE_RECORDS
#   TABLE_ROW_NUMBERS
#
# Outputs:
#   display table
#######################################
function table::display() {
  if [[ "${TABLE_ROW_NUMBERS}" == true ]]; then
    table::configure_row_numbers
  fi

  local total_columns="${#TABLE_HEADERS[@]}"
  local total_records="${#TABLE_RECORDS[@]}"
  local total_rows=$((total_records / total_columns))
  local columns_lengths=()

  # loop through headers column to set column character length.
  for (( i=0; i<total_columns; i++ )); do
    columns_lengths+=("${#TABLE_HEADERS[$i]}")
  done

  # loop throw each row column and get max character length for each column.
  for (( row_index=0; row_index<total_rows; row_index++ )); do

    for (( column_index=0; column_index<total_columns; column_index++ )); do
      local column="${TABLE_RECORDS[${array_index}]}"
      local column_current_length="${columns_lengths[${column_index}]}"

      if [[ ${#column} -gt ${column_current_length} ]];
      then
        columns_lengths["${column_index}"]="${#column}"
      fi

      ((array_index++))
    done
  done

  local header_string
  local column_string
  local column_border

  # build table row structure
  for (( i=0; i<total_columns; i++ )); do
    local column_max_length=$((columns_lengths[i] + 1))

    header_string="${header_string}| "
    header_string+="$(ansi "${TABLE_HEADERS_STYLE[@]}" %-${column_max_length}s)"
    column_string="${column_string}| %-${column_max_length}s"
    column_border="${column_border}+%-$((column_max_length + 1))s"
  done

  header_string="${header_string}|\n"
  column_string="${column_string}|\n"
  column_border="${column_border}+\n"

  printf "${column_border}" "" | tr " " -
  printf "${header_string}" "${TABLE_HEADERS[@]}"
  printf "${column_border}" "" | tr " " -
  printf "${column_string}" "${TABLE_RECORDS[@]}"
  printf "${column_border}" "" | tr " " -
}

#######################################
# Set the table headiings.
#
# Globals:
#   TABLE_HEADERS
#
# Arguments:
#   table headers
#######################################
function table::headers() {
  TABLE_HEADERS=("$@")
}

#######################################
# Set the table headers text style.
#
# Globals:
#   TABLE_HEADERS_STYLE
#
# Arguments:
#   ansi style
#######################################
function table::set_header_style() {
  TABLE_HEADERS_STYLE=("$@")
}

#######################################
# Store the records array for the
# table.
#
# Globals:
#   TABLE_RECORDS
#
# Arguments:
#   table records
#######################################
function table::set_records() {
  TABLE_RECORDS=("$@")
}

#######################################
# Enable/Disable the table row numbers.
#
# Globals:
#   TABLE_ROW_NUMBERS
#
# Arguments:
#   boolean
#######################################
function table::set_row_numbers() {
  TABLE_ROW_NUMBERS="${1}"
}
