{
  config,
  inputs,
  lib,
  self,
  ...
}: {
  perSystem = {
    config,
    pkgs,
    system,
    ...
  }: {
    devShells = let
      NIX_PATH = "nixpkgs=${inputs.nixpkgs}:unstable=${inputs.nixpkgs-unstable}";
      fixWrapper = pkgs.runCommand "fix-wrapper" {} ''
        mkdir -p $out/bin
        for i in ${pkgs.gcc.cc}/bin/*-gnu-gcc*; do
          ln -s ${pkgs.gcc}/bin/gcc $out/bin/$(basename "$i")
        done
        for i in ${pkgs.gcc.cc}/bin/*-gnu-{g++,c++}*; do
          ln -s ${pkgs.gcc}/bin/g++ $out/bin/$(basename "$i")
        done
      '';
    in {
      default = pkgs.mkShell {
        name = "devShell";
        buildInputs = with pkgs; [agenix] ++ basePkgs;

        inherit NIX_PATH;
      };
      openwrt = pkgs.buildFHSUserEnv {
        name = "openwrt-env";
        targetPkgs = pkgs:
          with pkgs; [
            git
            perl
            gnumake
            gcc
            unzip
            utillinux
            python3
            patch
            wget
            file
            subversion
            which
            pkgconfig
            openssl
            fixWrapper
            systemd
            binutils

            ncurses
            zlib
            zlib.static
            glibc.static
          ];
        multiPkgs = null;
        extraOutputsToInstall = ["dev"];
        profile = ''
          export hardeningDisable=all
          export NIXPKGS_ALLOW_INSECURE=1
        '';
      };
    };
  };
}
