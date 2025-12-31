#!/bin/bash
# Copyright (c) 2025 Andrew Davies, All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# 1- Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
# 
# 2- Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

trap "echo 'received SIGINT. Quitting.'; exit" SIGINT

function quit_with_err() {
	echo $* >&2
	exit 1
}

function parse_j6_device() {
	local devices
	devices=$(amidi -l | tail -n +2)
	if [[ -z ${devices} ]]; then
		return 0
	fi
	while IFS= read -r dev; do
		if [[ "${dev}" =~ "J-6 MIDI OUT"$ ]]; then
			echo "${dev}" | awk '{ print $2; }'
			break
		fi
	done <<< "${devices}"
}

function parse_j6_device_aconnect() {
	local devices
	devices=$(aconnect -i)
	if [[ -z ${devices} ]]; then
		quit_with_err "We could not find any input devices."
	fi
	while IFS= read -r dev; do
		if [[ "${dev}" =~ "J-6" ]]; then
			echo "${dev}" | awk '{ sub(/:/, ""); print $2; }'
			break
		fi
	done <<< "${devices}"
}

function parse_midi_through() {
	# Is this mostly copy-pasted from above? Yes.
	local devices
	devices=$(aconnect -o)
	if [[ -z ${devices} ]]; then
		quit_with_err "We could not find any output devices."
	fi
	while IFS= read -r dev; do
		if [[ "${dev}" =~ "Midi Through" ]]; then
			# We're making some load bearing assumptions here:
			# -- One midi device.
			# -- The format isn't gonna change for `aconnect -o`
			#    (probably, right?)
			# -- Port isn't going to be something other than zero.
			# -- Probably something else, I dunno.
			echo "${dev}" | awk '{ sub(/:/, ""); print $2; }'
			break
		fi
	done <<< "${devices}"
}

MIDI_THROUGH_IFACE="$(parse_midi_through)"
if [[ -z "$MIDI_THROUGH_IFACE" ]]; then
	quit_with_err "Could not find Midi Through interface"
fi
J6_DEV=""
while true; do
	J6_DEV=$(parse_j6_device)
	if [[ -n ${J6_DEV} ]]; then
		echo "Found at: ${J6_DEV}"
		echo "Now going to verify liveness."
		printf "Waiting for ten clock cycles (one dot per cycle)"
		# Occasionally we can expect CF 00 (I believe this is
		# program-change channel 16 to 0?).
		# According to https://midi.org/expanded-midi-1-0-messages-list
		#
		# however this isn't consistent (I usually have to click a
		# button for that (the horror)).
		#
		# Instead we'll do something silly: we'll wait for ten clock
		# messages from the device, which should be enough to know it's
		# alive, then connect it to the midi through device.
		CLOCK_COUNT=0
		amidi -p "${J6_DEV}" -c --dump | while read -r amidi_line; do
			if [[ "${amidi_line}" = "F8" ]]; then
				CLOCK_COUNT=$((CLOCK_COUNT+1))
				printf "."
			fi

			if [ "${CLOCK_COUNT}" -eq 10 ]; then
				break
			fi
		done
		J6_IFACE="$(parse_j6_device_aconnect)"
		if [[ -z "$J6_IFACE" ]]; then
			echo "Could not find device. Likely disconnected. Waiting again."
			continue
		fi
		printf "\nConnecting ${J6_IFACE}:0 to ${MIDI_THROUGH_IFACE}:0\n"
		aconnect "${J6_IFACE}:0" "${MIDI_THROUGH_IFACE}:0" || exit 1
		echo "Done"
		exit 0
	fi
	sleep 0.5
done
