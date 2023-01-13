# shellcheck shell=bash
#
# Define DEV.env global modules constants.

#######################################
# Module Directory
#######################################

readonly MODULE_DIR="${BIN_DIR}/lib/modules"
export MODULE_DIR

#######################################
# Store list of available modules.
#######################################

readonly MODULES_LIST=(
  "env"
  "prototype"
  "repos"
)

export MODULES_LIST
