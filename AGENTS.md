# AGENTS.md

This repository contains NixOS configurations using the numtide/blueprint
framework. All agentic coding agents must follow these guidelines.

## Build/Format/Lint Commands

```bash
nix develop                          # Enter development shell
nixfmt-rfc-style .                   # Format all Nix files
nixfmt --check .                     # Check formatting
nixos-rebuild build --flake .#tower  # Build configuration (example host)
nixos-rebuild test --flake .#tower   # Test (dry-run)
nixos-rebuild switch --flake .#tower # Apply configuration
nix build .#nixosConfigurations.tower.config.system.build.toplevel
agenix -e secret-name.age            # Generate secrets
nix build .#nixosConfigurations       # Build all configurations
nix eval .#nixosConfigurations.tower.config.system.build.toplevel
```

## Code Style Guidelines

### File Structure

- `hosts/` - Per-host configurations
- `modules/nixos/` - Reusable NixOS modules
- `modules/nixos/services/` - Service-specific modules
- `modules/nixos/containers/` - Podman containers (quadlet-nix)
- `packages/` - Custom package definitions
- `lib/` - Utility functions (use `flake.lib` helpers)
- `secrets/` - Encrypted secrets (managed by ragenix)

### Module Structure

```nix
{ pkgs, flake, lib, config, options, ... }:
let
  inherit (lib) mkIf mkOption types;
  inherit (flake.lib) mkBoolOpt mkOpt enabled disabled default nodefault;
  cfg = config.<module-name>;
in {
  options.<module-name> = { ... };
  config = mkIf cfg.enable { ... };
}
```

### Naming Conventions

- Host names: lowercase, kebab-case (e.g., `tower`, `lsrv`)
- Module options: dot notation (e.g., `hw.gpu`, `desktop.enable`)
- Helpers: camelCase (e.g., `mkOpt`, `mkSecret`)
- Files: lowercase, kebab-case (e.g., `web-server.nix`)
- Variables: camelCase in let bindings

### Helper Functions (from flake.lib)

- `mkOpt type default` - Create option with type and default
- `mkBoolOpt default` - Create boolean option
- `mkIntOpt default` - Create integer option
- `mkStrOpt default` - Create string option
- `enabled` - `{ enable = true; }`
- `disabled` - `{ enable = false; }`
- `default` - `{ enable = mkDefault true; }`
- `nodefault` - `{ enable = mkDefault false; }`
- `mkSecret { file, owner?, group?, mode? }` - Secret file config
- `create-caddy-proxy` - Caddy reverse proxy config
- `btrfsVolume` - BTRFS volume configuration
- `mountVolume` - Volume mount specification

### Import Patterns

```nix
inherit (lib) mkIf mkOption mkDefault types attrNames filterAttrs mapAttrs;
inherit (flake.lib) mkBoolOpt enabled;

# Conditional config
let inherit (lib) mkIf; cfg = config.some.module;
in { config = mkIf cfg.enable { ... }; }
```

### Option Definitions

```nix
# Boolean
options.my.module = { enable = mkBoolOpt false; };

# Enum
options.hw.gpu = mkOpt (enum ["amd" "nvidia" "intel" "vm" "other"]) "other";
```

### Container Configuration (quadlet-nix)

```nix
{ inherit (lib) mkIf mkForce; inherit (flake.lib) btrfsVolume mountVolume mkBoolOpt; }:
{
  config = mkIf config.cnt.some-container.enable {
    virtualisation.quadlet = {
      pods.some-pod.podConfig = { ... };
      volumes.some-volume = btrfsVolume config.disko { subvol = "@volumes/some"; };
      containers.some-container.containerConfig = {
        image = "docker.io/image:tag";
        pod = pods.some-pod.ref;
        mounts = [ ... ];
        environments = { ... };
      };
    };
  };
}
```

### Package Definitions

```nix
{ pkgs, pname, ... }:
pkgs.stdenv.mkDerivation rec {
  inherit pname;
  version = "x.y.z";
  src = pkgs.fetchurl { ... };
  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    ...
    runHook postInstall
  '';
  meta = {
    description = "...";
    homepage = "https://...";
    license = pkgs.lib.licenses.<license>;
    mainProgram = "<program-name>";
  };
}
```

### Formatting & Style Rules

- Use nixfmt-rfc-style for all Nix files
- Indentation: 2 spaces
- No trailing semicolons at top level
- Align list items where reasonable
- Keep let bindings concise and related

### Error Handling

- Use `throw "message"` for errors (e.g., unsupported systems)
- Wrap conditionals in `mkIf` where possible
- Provide sensible defaults using `mkDefault`
- Document required configuration in comments

### Comments

- Use `#` for single-line comments
- Document module purposes at the top
- Comment complex logic or workarounds
- Keep comments brief and relevant

### Inputs Usage

- Follow nixpkgs: `inputs.some-input.follows = "nixpkgs"`
- Use unstable packages: `inputs.nixpkgs-unstable`
- Access flake inputs via `inputs` in module arguments
- Reference custom packages via `flake.packages.${pkgs.system}`

### Testing & CI/CD

- Always test with `nixos-rebuild build` before `switch`
- Use `--dry-run` or `test` for dry runs
- Verify syntax with `nixfmt --check`
- Garnix CI builds all `nixosConfigurations.*` automatically
- GitHub Actions in `.github/workflows/` for additional checks
