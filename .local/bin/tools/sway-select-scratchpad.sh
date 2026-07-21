#!/bin/sh
# TODO: If using --criteria on a window in another workspace, sway switches to that workspace
USAGE="\
${0} [--id|--criteria] <index|id|criteria>

Focus/hide the container at <index> in the scratchpad
Depends:
    jq

Args:
    --id: Use the given container ID instead of <index>
    --criteria: Use the given criteria instead of <index>
    index: The element index of the scratchpad (sorted by container id)
    id: The container id (if --use-id is specified)
    critera: The critera to use for swaymsg (if --use-critera is specified)

Caution: the list is sorted by container id - not the order it was put into the scratchpad...
         for more complex use cases, use either \`--use-id\` or \`--use-critera\`
             ${0} --use-criteria [con_mark=_scratchpad_term]
"

set -o errexit
set -o nounset

use_criteria=false
use_id=false

case "${1:-}" in
	--id) use_id=true ; shift ;;
	--criteria) use_criteria=true ; shift ;;
esac

if [ $# -ne 1 ] ; then
	printf "%s" "${USAGE}"
	exit 1
fi

if ${use_criteria} ; then
	# ensure criteria doesn't have brackets: [blah] -> blah
	criteria="$(echo "${1}" | sed -E 's/\[(.*)\]/\1/')"
	# mark any window meeting the criteria
	swaymsg -- "[${criteria}] mark --add __temp_mark"
fi

sway_tree="$(swaymsg -t get_tree | jq -r '.nodes[].nodes[]')"

${use_criteria} && swaymsg -- "[con_mark=__temp_mark] unmark __temp_mark" &

windows_in_scratch="$(printf "%s" "${sway_tree}" | jq -r 'select(.name == "__i3_scratch") | .floating_nodes[].id')"
if ${use_criteria} ; then
	window_id="$(printf "%s" "${sway_tree}" | jq -r '.. | select(.marks? | index("__temp_mark")) | .id')"
elif ${use_id} ; then
	window_id=${1}
else
	window_id="$(printf "%s" "${sway_tree}"  | jq -r "select(.name == \"__i3_scratch\") | .focus | sort | .[${1}-1] // \"\"")"
fi

if [ -z "${window_id}" ] ; then
	echo "No window ids found"
	exit 2
fi

echo "${window_id}"
if echo "${windows_in_scratch}" | grep -q "${window_id}" ; then
	swaymsg "[con_id=${window_id}] focus"
else
	swaymsg "[con_id=${window_id}] move container to scratchpad"
fi
