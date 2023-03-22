# shellcheck shell=bash
#
# Define DEV.env global filesystem constants.

#######################################
# Root Directory
#######################################

PROJECT_DIR="$( dirname "${BIN_DIR}" )"
readonly PROJECT_DIR
export PROJECT_DIR

#######################################
# Template Directory
#######################################

readonly TEMPLATE_DIR="${PROJECT_DIR}/templates"
export TEMPLATE_DIR
