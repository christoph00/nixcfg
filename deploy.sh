#!/usr/bin/env bash

set -e

USAGE=<<EOF
apply.sh {dry-build|build|activate|dry-activate|switch} TARGET_HOST [ ... ]

This expects to be run from under the flake repository.
Extra args are passed to nixos-rebuild directly.
EOF

local_hostname="$(hostname -s)"
command="${1?}"
target="${2?}"
shift 2
extra_args=$*

if [ $target == $local_hostname ]; then
	set -x
	nixos-rebuild --flake .# --use-remote-sudo --fast "${command?}" ${extra_args}
else
	set -x
	NIX_SSHOPTS=-A nixos-rebuild "${command?}" --flake ".#${target?}" --target-host "${target?}.netbird.cloud" --use-remote-sudo --use-substitutes ${extra_args}
fi

