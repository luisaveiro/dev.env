# shellcheck shell=bash
#
# Define global constants.

PROJECT_DIR=$(dirname "${CURRENT_DIR}")
readonly PROJECT_DIR
readonly SETUP_DIR="${PROJECT_DIR}/setups"
readonly TEMPLATES_DIR="${PROJECT_DIR}/templates"

export PROJECT_DIR SETUP_DIR TEMPLATES_DIR
