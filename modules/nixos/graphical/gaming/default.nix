{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  inputs,

  # Additional metadata is provided by Snowfall Lib.
  namespace, # The namespace used for your flake, defaulting to "internal" if not set.
  system, # The system architecture for this host (eg. `x86_64-linux`).
  target, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format, # A normalized name for the system target (eg. `iso`).
  virtual, # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems, # An attribute map of your defined hosts.

  # All other arguments come from the module system.
  config,

  ...
}:

with builtins;
with lib;
with lib.internal;

let
  cfg = config.internal.graphical.gaming;
in
{

  options.internal.graphical.gaming = {
    enable = mkBoolOpt config.internal.isDesktop "Enable the Gaming.";
    enableStreaming = mkBoolOpt cfg.enable "Enable Game Streaming Host.";
  };

  config = mkIf cfg.enable {
    chaotic.steam.extraCompatPackages = with pkgs; [
      proton-ge-custom
    ];

    environment.systemPackages = [
      pkgs.heroic
    ];
    chaotic.mesa-git.extraPackages = with pkgs; [
      rocmPackages.clr.icd
      rocmPackages.clr
      # mesa_git.opencl
    ];
    environment.variables.RADV_PERFTEST = "sam,video_decode,transfer_queue";

    #chaotic.mesa-git.enable = true;

    programs.steam = {
      enable = true;
      gamescopeSession = {
        enable = true; # Gamescope session is better for AAA gaming.
        args = [
          "--immediate-flips"
          "--"
          "bigsteam"
        ];
      };
    };
    programs.gamescope = {
      enable = true;
      capSysNice = false; # capSysNice freezes gamescopeSession for me.
      args = [ ];
      env = lib.mkForce {
        # I set DXVK_HDR in the alternative-sessions script.
        ENABLE_GAMESCOPE_WSI = "1";
      };
      package = pkgs.gamescope_git;
    };

    ## DP-2 = Monitor  HDMI-A-1 = Dummy
    services.sunshine = mkIf cfg.enableStreaming {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
      settings = {
        encoder = "amdvce";
        fec_percentage = "7";
        capture = "wlr";
      };
      applications = {

        env = {
          PATH = "$(PATH)";
        };

        apps =
          let
            steam = lib.getExe config.programs.steam.package + " --";
            prep = {
              do = pkgs.writeScript "set-wlr-res" ''
                #!/bin/sh
                ${pkgs.wlr-randr}/bin/wlr-randr --output HDMI-A-1 --off --output HEADLESS-1 --custom-mode ''${SUNSHINE_CLIENT_WIDTH}x''${SUNSHINE_CLIENT_HEIGHT}@''${SUNSHINE_CLIENT_FPS}
              '';
              undo = ''${pkgs.bash}/bin/bash -c "${pkgs.wlr-randr}/bin/wlr-randr --output HDMI-A-1 --off --output HEADLESS-1 --custom-mode 1920x1080@60"'';
            };
            mk-icon =
              { icon-name }:
              pkgs.runCommand "${icon-name}-scaled.png" { }
                ''${pkgs.imagemagick}/bin/convert -density 1200 -resize 500x -background none ${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark/128x128/apps/${icon-name}.svg -gravity center -extent 600x800 $out'';
            download-image =
              {
                url,
                hash,
              }:
              let
                image = pkgs.fetchurl { inherit url hash; };
              in
              pkgs.runCommand "${lib.nameFromURL url "."}.png" { }
                ''${pkgs.imagemagick}/bin/convert ${image} -background none -gravity center -extent 600x800 $out'';
          in
          [
            {
              name = "Desktop";
              prep-cmd = [ prep ];
              image-path = mk-icon { icon-name = "cinnamon-virtual-keyboard"; };
            }

            {
              name = "Steam Big Picture";
              cmd = "${steam} -gamepadui";
              prep-cmd = [ prep ];
              image-path = mk-icon { icon-name = "steamlink"; };
            }
            {
              name = "Steam (Regular UI)";
              cmd = "${steam}";
              prep-cmd = [ prep ];
              image-path = mk-icon { icon-name = "steam"; };
            }
          ];
      };
    };

    # Allows streaming with KMS
    # security.wrappers.sunshine = mkIf cfg.enableStreaming {
    #   source = "${pkgs.sunshine}/bin/sunshine";
    #   capabilities = "cap_sys_admin+pie";
    #   owner = "root";
    #   group = "root";
    # };

  };

}
