# shellcheck shell=bash
#
# Table package.

TABLE_HEADERS=()
TABLE_HEADERS_STYLE=("--white" "--bold")
TABLE_RECORDS=()
TABLE_ROW_NUMBERS="false"

#######################################
# Add row numbers to table
#
# Globals:
#   TABLE_HEADERS
#   TABLE_RECORDS
#######################################
function table::configure_row_numbers() {
  local table_total_columns="${#TABLE_HEADERS[@]}"
  local table_total_records="${#TABLE_RECORDS[@]}"
  local table_total_rows=$((table_total_records / table_total_columns))
  local table_columns_lengths=()
  local temporary_table_records=()

  local row_start_index=0 column_start_index=0 array_index=0

  # loop through records and add  row number
  for (( row_index=row_start_index; row_index<table_total_rows; row_index++ ))
  do
    if [[ ${row_index} == 0 ]]; then
      array_column_start="0"
      array_column_end="${table_total_columns}"
    else
      array_column_end=$(( (row_index + 1) * table_total_columns ))
      array_column_start=$(( (array_column_end - table_total_columns) ))
    fi

    local row_records=(
      "$((row_index + 1))"
      "${TABLE_RECORDS[@]:${array_column_start}:${table_total_columns}}"
    )

    temporary_table_records+=("${row_records[@]}")
  done

  TABLE_HEADERS=("#" "${TABLE_HEADERS[@]}")
  TABLE_RECORDS=("${temporary_table_records[@]}")
}

#######################################
# Set table headers
#
# Globals:
#   TABLE_HEADERS
#
# Arguments:
#   table headers
#######################################
function table::header() {
  TABLE_HEADERS=("$@")
}

#######################################
# Set table headers text style
#
# Globals:
#   TABLE_HEADERS_STYLE
#
# Arguments:
#   ansi style
#######################################
function table::header_style() {
  TABLE_HEADERS_STYLE=("$@")
}

#######################################
# Display table
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
  if [[ ${TABLE_ROW_NUMBERS} == "true" ]]; then
    table::configure_row_numbers
  fi

  local table_total_columns="${#TABLE_HEADERS[@]}"
  local table_total_records="${#TABLE_RECORDS[@]}"
  local table_total_rows=$((table_total_records / table_total_columns))
  local index=0 table_columns_lengths=()

  # loop through headers column to set column character length.
  for (( i=index; i<table_total_columns; i++ ))
  do
    table_columns_lengths+=("${#TABLE_HEADERS[$i]}")
  done

  local row_start_index=0 column_start_index=0 array_index=0

  # loop throw each row column and get max character length for each column.
  for (( row_index=row_start_index; row_index<table_total_rows; row_index++ ))
  do
    column_start_index=0

    for (( column_index=column_start_index; column_index<table_total_columns; column_index++ ))
    do
      local column="${TABLE_RECORDS[${array_index}]}"
      local column_current_length="${table_columns_lengths[${column_index}]}"

      if [[ ${#column} -gt ${column_current_length} ]];
      then
        table_columns_lengths[${column_index}]=${#column}
      fi

      ((array_index++))
    done
  done

  local header_string column_string column_border

  # build table row structure
  for (( i=index; i<table_total_columns; i++ ))
  do
    local column_max_length=$((table_columns_lengths[i] + 1))
    header_string="${header_string}| $(ansi "${TABLE_HEADERS_STYLE[@]}" %-${column_max_length}s)"
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

function table::row_numbers() {
  TABLE_ROW_NUMBERS="$1"
}

#######################################
# Store records array for table
#
# Globals:
#   TABLE_RECORDS
#
# Arguments:
#   table records
#######################################
function table::records() {
  TABLE_RECORDS=("$@")
}
