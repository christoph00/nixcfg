{
  flake,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with flake.lib;
let
  cfg = config.shell;
in
{
  imports = [
    ./neovim
    ./devtools.nix
  ];
  options.shell = with types; {
    enable = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    environment.enableAllTerminfo = true;
    programs.direnv = enabled;
    programs.git = enabled;
    environment.systemPackages = with pkgs; [
      htop
      wget
      ripgrep
      unzip
      pciutils
      jq
      jc
      killall
      rsync
      usbutils
      uutils-coreutils-noprefix
      dnsutils
      fzf
    ];
    environment.shells = with pkgs; [
      nushell
      dash
    ];

    home.rum.programs.nushell = {
      enable = true;
      settings = {
        edit_mode = "vi";
        buffer_editor = "nvim";
        show_banner = false;
        history = {
          file_format = "sqlite";
          max_size = "1_000_000";
          sync_on_enter = true;
          isolation = false;
        };
        table = {
          mode = "light";
          index_mode = "auto";
        };
      };
      aliases = {
        ll = "ls -l";

      };
      # plugins = with pkgs.nushellPlugins; [
      #  units
      #  formats
      #  query
      # ];
      extraConfig = ''
      $env.PATH = ($env.PATH | prepend ($env.HOME + "/.bun/bin"))
          const profile_file = $"($nu.home-path)/.profile.nu"

          const file_to_source = if ($profile_file | path exists) {
              $profile_file
          } else {
              null
          }

          source $file_to_source
        '';

    };

  };
}
