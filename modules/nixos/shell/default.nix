{ options
, config
, pkgs
, lib
, inputs
, ...
}:
with lib;
with lib.internal;
let
  cfg = config.internal.shell;

  wrapped = inputs.wrapper-manager.lib.build {
    inherit pkgs;
    modules = [
      {
        wrappers = {
          git = { basePackage = pkgs.git; };
        };
      }
    ];
  };

  v3 = with pkgs.pkgsx86_64_v3-core; [
    curl
    bash
    elfutils
    diffutils
    debugedit
    file
    less
    which
  ];
in
{
  options.internal.shell = with types; {
    enable = mkBoolOpt true "Whether or not to configure shell config.";
  };

  config = mkIf cfg.enable {

    # environment.enableAllTerminfo = true;
    programs.direnv.enable = true;
    environment.systemPackages = [
      wrapped
      pkgs.htop
      pkgs.doas-sudo-shim
      pkgs.wget
      # pkgs.neovim
      pkgs.github-cli
      pkgs.gcc
      pkgs.ripgrep
      pkgs.unzip
      pkgs.pciutils
      pkgs.jq
      pkgs.killall
      pkgs.nh
      pkgs.devenv
      pkgs.tmux
    ];
  };
}
