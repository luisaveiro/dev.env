# shellcheck shell=bash
#
# Define DEV.env global Git constants.

#######################################
# Git Regex Pattern
#######################################

readonly GIT_REGEX="^(https|git)(:\/\/|@)([^\/:]+)[\/:]([^\/:]+)\/(.+).git$"
export GIT_REGEX

#######################################
# Git Repository
#######################################

readonly GIT_REPOSITORY="https://github.com/luisaveiro/dev.env"
export GIT_REPOSITORY
