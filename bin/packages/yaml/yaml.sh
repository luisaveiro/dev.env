# shellcheck shell=bash
#
# Yaml package.
#
# Based on https://github.com/jasperes/bash-yaml

#######################################
# Retrieve yaml elements from a yaml file.
#
# Arguments:
#   --file
#   --prefix
#######################################
function yaml::parse_yaml() {
  local arguments_list=("file" "prefix")
  local s w fs file prefix

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

  s='[[:space:]]*'
  w='[a-zA-Z0-9_.-]*'
  fs="$(echo @|tr @ '\034')"

  (
    sed -e '/- [^\“]'"[^\']"'.*: /s|\([ ]*\)- \([[:space:]]*\)|\1-'\$'\n''  \1\2|g' |

    sed -ne '/^--/s|--||g; s|\"|\\\"|g; s/[[:space:]]*$//g;' \
      -e 's/\$/\\\$/g' \
      -e "/#.*[\"\']/!s| #.*||g; /^#/s|#.*||g;" \
      -e "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
      -e "s|^\($s\)\($w\)${s}[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" |

    awk -F "$fs" '{
      indent = length($1)/2;

      if (length($2) == 0) { conj[indent]="+";} else {conj[indent]=""; }

      vname[indent] = $2;

      for (i in vname) {if (i > indent) {delete vname[i]}}
        if (length($3) > 0) {
          vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
          printf("%s%s%s%s=(\"%s\")\n", "'"${prefix}"'",vn, $2, conj[indent-1], $3);
        }
      }' |

    sed -e 's/_=/+=/g' |

    awk '
      BEGIN {
        FS="=";
        OFS="="
      }
      /(-|\.).*=/ {
        gsub("-|\\.", "_", $1)
      }
      { print }
    '
  ) < "${file}"
}

#######################################
# Validate element exists in YAML
#
# Arguments:
#   --element
#   YAML
#
# Returns:
#   0 if element exists.
#   1 if element does not exsits.
#######################################
function yaml::validate() {
  local arguments_list=("element")
  local element yaml=$*

  while [ $# -gt 0 ]; do
    if [[ $1 == *"--"* && $1 == *"="* ]]; then
      local argument="${1/--/}"
      IFS='=' read -ra parameter <<< "${argument}"

      if [[ "${arguments_list[*]}" =~ ${parameter[0]} ]]; then
        yaml="${yaml/--${argument}/}"
        declare "${parameter[0]}"="${parameter[1]}"
      fi
    fi

    shift
  done

  [[ $yaml == *"${element}"* ]] && return 0 || return 1
}
