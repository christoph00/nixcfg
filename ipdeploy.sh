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
remote="${3?}"
shift 3
extra_args=$*

set -x
NIX_SSHOPTS=-A nixos-rebuild "${command?}" --flake ".#${target?}" --target-host "${remote?}" --use-substitutes --fast ${extra_args}

