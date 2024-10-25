{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # You also have access to your flake's inputs.
  inputs,
  # The namespace used for your flake, defaulting to "internal" if not set.
  namespace,
  # All other arguments come from NixPkgs. You can use `pkgs` to pull shells or helpers
  # programmatically or you may add the named attributes as arguments here.
  pkgs,
  mkShell,
  ...
}:

# The `bootstrap` command provided in this shell will
# create a temporary directory to store various files
# that should be copied over to the target system.
#
# The SSH Host Private Key of the target system is among them,
# because it is required to decrypt Agenix secrets,
# meaning that the only way to avoid a catch-22 of
# needing the SSH Host Private Key to decrypt the SSH Host
# Private Key is to get it onto the system out-of-tree.
#
# The SSH Host Public Key, while not stored in this repository,
# is derived from the SSH Host Private Key. The `bootstrap`
# command will also generate the correct SSH Host Public Key,
# and add it to the list of files copied over to the target
# system before rebooting into the new OS for the first time.

# NOTICE
# Using a local copy of nixos-anywhere due to this
# bug in upstream nix:
# https://github.com/nix-community/nixos-anywhere/issues/347
#
# TODO remove this workaround when the bug is fixed

mkShell {
  shellHook = ''
    export EDITOR="hx"
    export RULES="./secrets.nix"

    decrypt() {
      agenix --editor cat --edit "$1" | grep -v "wasn't changed"
    }

    sysdecrypt() {
      decrypt "systems/$arch/$hostname/secrets/$1.age"
    }

    bootstrap() {
      temp=$(mktemp -d)
      cleanup() {
        rm -rf "$temp"
      }
      trap cleanup EXIT

      ssh="$temp/state/etc/ssh"
      key="$ssh/ssh_host_ed25519_key"

      mkdir -p "$ssh" && chmod 755 "$ssh"
      sysdecrypt ssh_host_ed25519_key > "$key" && chmod 600 "$key"
      openssl pkey -in "$key" -pubout > "$key.pub" && chmod 644 "$key.pub"

      ./shells/devel/nixos-anywhere.sh "root@$ip" \
        --flake ".#$hostname" \
        --build-on-remote \
        --print-build-logs \
        --extra-files "$temp" \
        --disk-encryption-keys \
          /tmp/disk.key <(sysdecrypt "luks/disk/password") \
        --option eval-cache false \
        --option show-trace true \
        "$@"
    }
  '';

  packages = with pkgs; [
    nix
    coreutils-full
    git
    gh
    openssh
    openssl
    dbus
    rsync
    helix
    nixd
    nixos-anywhere
    agenix
    nh
    just
    disko-install
  ];
}
