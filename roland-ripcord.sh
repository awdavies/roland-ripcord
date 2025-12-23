#!/bin/bash
CMD=$@
if [[ -z ${CMD} ]]; then
	trap "echo 'received SIGINT. Quitting.'; exit" SIGINT
else
	trap "echo 'received SIGINT. Quitting then running command ${CMD}'; ${CMD}; exit" SIGINT
fi

function parse_j6_device() {
	local devices
	devices=$(amidi -l | tail -n +2)
	if [[ -z ${devices} ]]; then
		return 0
	fi
	while IFS= read -r dev; do
		if [[ "${dev}" =~ "J-6 MIDI OUT"$ ]]; then
			echo "${dev}" | awk '{ print $2; }'
		fi
	done <<< "${devices}"
}

J6_DEV=""
while true; do
	J6_DEV=$(parse_j6_device)
	if [[ -n ${J6_DEV} ]]; then
		echo "Found it. Dumping at: ${J6_DEV}"
		amidi -p "${J6_DEV}" --dump
	fi
	sleep 0.5
done
