default:
  just --list


rebuild host:
  nixos-rebuild  --use-substitutes --no-build-nix --build-host chsitoph@{{host}} --target-host christoph@{{host}} --use-remote-sudo switch --refresh --flake github:christoph00/nixcfg#{{host}}

up:
  nix flake update

gc:
  doas nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 7d && doas nix store gc

repair:
  doas nix-store --verify --check-contents --repair


