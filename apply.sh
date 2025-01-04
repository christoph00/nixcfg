#!/usr/bin/env bash

set -euo pipefail

if [ $# -ne 2 ] || [[ ! "$2" =~ ^(boot|switch)$ ]]; then
    echo "Usage: $0 <remote-hostname> <boot|switch>"
    echo "  boot   - Aktiviert Konfiguration beim nächsten Boot"
    echo "  switch - Aktiviert Konfiguration sofort"
    exit 1
fi

REMOTE_HOST="$1"
ACTIVATION_MODE="$2"
REMOTE_USER="$(whoami)"

echo "Building system configuration for $REMOTE_HOST..."
nix build .#nixosConfigurations."$REMOTE_HOST".config.system.build.toplevel --impure

CLOSURE_PATH="$(readlink -f result)"
echo "Built closure at: $CLOSURE_PATH"

echo "Copying closure to $REMOTE_HOST..."
nix-copy-closure --to "$REMOTE_USER@$REMOTE_HOST" "$CLOSURE_PATH"

echo "Activating configuration on $REMOTE_HOST with mode: $ACTIVATION_MODE..."
ssh "$REMOTE_USER@$REMOTE_HOST" "doas nix-env -p /nix/var/nix/profiles/system --set $CLOSURE_PATH && doas $CLOSURE_PATH/bin/switch-to-configuration $ACTIVATION_MODE"

if [ "$ACTIVATION_MODE" = "boot" ]; then
    echo "Configuration will be activated on next boot"
    echo "You may want to reboot the system: ssh $REMOTE_USER@$REMOTE_HOST 'doas reboot'"
else
    echo "Configuration activated successfully!"
fi
