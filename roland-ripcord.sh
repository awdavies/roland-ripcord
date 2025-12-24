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

CMD=$*
if [[ -z ${CMD} ]]; then
	trap "echo 'received SIGINT. Quitting.'; exit" SIGINT
else
	trap "echo 'received SIGINT. Quitting then running command \"${CMD}\".'; ${CMD}; exit" SIGINT
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
		echo "Found it. Dumping: ${J6_DEV}"
		amidi -p "${J6_DEV}" --dump
	fi
	sleep 0.5
done
