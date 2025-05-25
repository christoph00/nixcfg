{
  config,
  lib,
  flake,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    concatStringsSep
    mapAttrsToList
    ;
  inherit (lib.types) attrsOf attrs submodule;
  inherit (flake.lib) mkOpt mkStrOpt mkStrOptNull;
  cfg = config.desktop;

  gamesToApps =
    games:
    lib.mapAttrsToList (
      name: game:
      let
        gameName = if game.name != null then game.name else name;
        iconPath =
          if game.cover.url != null then
            "${pkgs.fetchurl {
              url = game.cover.url;
              sha256 = game.cover.sha256;
            }}"
          else
            null;
      in
      {
        name = gameName;
        cmd = "${pkgs.uwsm}/bin/uwsm-app -s games.slice -a game-${name} game-${name}.desktop";
        image-path = iconPath;
      }
    ) games;
in
{
  options.desktop = {

    games = mkOpt (attrsOf (submodule {
      options = {
        name = mkStrOptNull;
        exe = mkStrOpt "winecfg";
        gameid = mkStrOpt "umu-default";
        store = mkStrOpt "NONE";
        env = mkOpt attrs { };
        icon = {
          url = mkStrOptNull;
          sha256 = mkStrOptNull;
        };
        cover = {
          url = mkStrOptNull;
          sha256 = mkStrOptNull;
        };
      };
    })) { };
  };

  config = mkIf cfg.gaming.enable {
    home.files =
      let
        defaultEnv = {
          PROTON_ENABLE_WAYLAND = "1";
          PROTONPATH = "${cfg.gaming.proton}";
          PROTON_USE_NTSYNC = "1";
          # SDL_VIDEODRIVER = "windows";
        };
      in
      lib.mapAttrs' (
        name: game:
        let
          envVars =
            defaultEnv
            // game.env
            // {
              STORE = game.store;
              GAMEID = game.gameid;
            };
          envStr = concatStringsSep " " (mapAttrsToList (n: v: "${n}=${v}") envVars);
          icon = builtins.fetchurl {
            url = "${game.icon.url}";
            sha256 = "${game.icon.sha256}";
          };
          gameName = if game.name != null then game.name else name;
        in
        {
          name = ".local/share/applications/game/${name}.desktop";
          value = {
            text = ''
              [Desktop Entry]
              Name=${gameName}
              Comment=Launch ${gameName}
              Exec=env ${envStr} ${pkgs.umu-launcher}/bin/umu-run "${game.exe}"
              Type=Application
              Categories=Game;
              Icon=${icon}
              Actions=WineConfig;CustomExe;
              MimeType=application/x-ms-dos-executable;application/x-msdos-program;application/exe;application/x-exe;application/dos-exe;

              [Desktop Action WineConfig]
              Name=Wine Configuration
              Exec=env ${envStr} ${pkgs.umu-launcher}/bin/umu-run winecfg

              [Desktop Action CustomExe]
              Name=Custom Executable
              Exec=env ${envStr} ${pkgs.umu-launcher}/bin/umu-run %f
            '';
          };
        }
      ) config.desktop.games;

    services.sunshine.applications = {
      env = {
        PATH = "$(PATH):$(HOME)/.local/bin";
      };
      apps = (gamesToApps config.desktop.games) ++ [
        {
          name = "Desktop";
          auto-detach = "true";
        }
      ];
    };

  };

}
