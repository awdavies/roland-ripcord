#!/bin/bash
trap "echo 'received SIGINT. Quitting.'; exit" SIGINT

function parse_j6_device() {
	local devices
	devices=$(amidi -l | tail -n +2)
	if [[ -n ${devices} && ${devices} =~ "J-6 MIDI OUT"$ ]]; then
		echo "${devices}" | awk '{ print $2; }'
	fi
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
