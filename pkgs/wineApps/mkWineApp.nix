# from https://github.com/lucasew/nixcfg/blob/master/pkgs/wrapWine.nix
{pkgs}: let
  inherit (builtins) length concatStringsSep;
  inherit (pkgs) lib cabextract winetricks writeShellScriptBin;
  inherit (lib) makeBinPath;
in
  {
    is64bits ? true,
    wine ?
      if is64bits
      then pkgs.wineWowPackages.staging
      else pkgs.wine,
    wineFlags ? "",
    executable,
    prefix,
    chdir ? null,
    name,
    tricks ? [],
    setupScript ? "",
    firstrunScript ? "",
    gamescope ? false,
    gamescope_args ? "-W 1920 -H 1080",
  }: let
    wineBin = "${wine}/bin/wine${
      if is64bits
      then "64"
      else ""
    }";
    requiredPackages = [
      wine
      cabextract
      winetricks
    ];
    PATH = makeBinPath requiredPackages;
    NAME = name;
    PREFIX = prefix;
    WINEARCH =
      if is64bits
      then "win64"
      else "win32";
    preCmd =
      if gamescope_args
      then "${pkgs.gamescope}/bin/gamescope ${gamescope_args} -- "
      else "";
    setupHook = ''
      ${wine}/bin/wineboot
    '';
    tricksHook =
      if (length tricks) > 0
      then let
        tricksStr = concatStringsSep " " tricks;
        tricksCmd = ''
          ${winetricks}/bin/winetricks ${tricksStr}
        '';
      in
        tricksCmd
      else "";
    script = writeShellScriptBin name ''
      export APP_NAME="${NAME}"
      export WINEARCH=${WINEARCH}
      export PATH=$PATH:${PATH}
      export WINEPREFIX="${PREFIX}"
      export EXECUTABLE="${executable}"
      export WLR_NO_HARDWARE_CURSORS=1
      ${setupScript}
      if [ ! -d "$WINEPREFIX" ] # if the prefix does not exist
      then
        ${setupHook}
        # ${wineBin} cmd /c dir > /dev/null 2> /dev/null # initialize prefix
        wineserver -w
        ${tricksHook}
        ${firstrunScript}
      fi
      ${
        if chdir != null
        then ''cd "${chdir}"''
        else ""
      }
      if [ ! "$REPL" == "" ]; # if $REPL is setup then start a shell in the context
      then
        bash
        exit 0
      fi

      ${preCmd}${wineBin} ${wineFlags} "$EXECUTABLE" "$@"
      wineserver -w
    '';
  in
    script
