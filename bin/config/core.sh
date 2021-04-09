# shellcheck shell=bash
#
# Define global constants.

readonly PROJECT_DIR=$(dirname "${CURRENT_DIR}")
readonly SETUP_DIR="${PROJECT_DIR}/setups"
readonly TEMPLATES_DIR="${PROJECT_DIR}/templates"

export PROJECT_DIR SETUP_DIR TEMPLATES_DIR
