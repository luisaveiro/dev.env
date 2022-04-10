# shellcheck shell=bash
#
# SonarQube status message

#######################################
# Output support Ukraine message to terminal.
#######################################
function message::supportUkraine() {
  hashtag="$(ansi --bold --white --bg-blue "#StandWith")"
  hashtag="${hashtag}$(ansi --bold --black --bg-yellow Ukraine)"

  output --newline=top "${hashtag}"

  quote="It's not enough that we do our best; sometimes we have to do what's required."
  output "$(ansi --italic "${quote}") — $(ansi --bold Winston Churchill)."

  output --newline=bottom "Support Ukraine by visiting" \
    "$(ansi --bold --white https://supportukrainenow.org)"
}
