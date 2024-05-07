{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.apps.nemo;
  # Remove services that make Nemo hide most of my devices...
  gvfs = pkgs.runCommandLocal "gvfs-remove-junk" {} ''
    mkdir -p "$out"/share/dbus-1
    cp --no-preserve=mode -r "${pkgs.gnome.gvfs}"/share/{systemd,dbus-1} "$out"/share/.
    for file in "$out"/share/systemd/user/gvfs-*; do
      case "$(basename "$file")" in
        gvfs-daemon*|gvfs-metadata*) ;;
        *) rm "$file" ;;
      esac
    done
    for file in "$out"/share/dbus-1/services/*; do
      case "$(basename "$file")" in
        *Daemon*|*Metadata*) ;;
        *) rm "$file" ;;
      esac
    done
  '';
in {
  options.chr.apps.nemo = with types; {
    enable = mkBoolOpt' config.chr.desktop.enable;
  };

  config = mkIf cfg.enable {
    chr.home = {
      extraOptions = {
        home.packages = with pkgs; [
          pkgs.gnome.file-roller
          gvfs
          pkgs.cinnamon.nemo
          pkgs.cinnamon.nemo-fileroller
        ];
        dconf.settings."org/nemo/window-state" = {
          start-with-menu-bar = false;
        };

        xdg.mimeApps.defaultApplications = {
          "inode/directory" = ["nemo.desktop"];
        };

        xdg.dataFile."nemo/actions/extract-here.nemo_action".text = ''
          [Nemo Action]
          Active=true
          Name=Extract here
          Comment=Extract here
          Exec=${pkgs.gnome.file-roller}/bin/file-roller --extract-here %F
          Icon-Name=gnome-mime-application-x-compress
          Selection=Any
          Extensions=zip;7z;ar;cbz;cpi;exe;iso;jar;tar;tar.z;tar.bz2;tar.gz;tar.lz;tar.lzma;tar.xz
          Quote=double
        '';

        xdg.dataFile."nemo/actions/extract-to.nemo_action".text = ''
          [Nemo Action]
          Active=true
          Name=Extract to ...
          Comment=Extract to ...
          Exec=${pkgs.gnome.file-roller}/bin/file-roller --extract %F
          Icon-Name=gnome-mime-application-x-compress
          Selection=Any
          Extensions=zip;7z;ar;cbz;cpi;exe;iso;jar;tar;tar.z;tar.bz2;tar.gz;tar.lz;tar.lzma;tar.xz
          Quote=double
        '';

        xdg.dataFile."nemo/actions/compress.nemo_action".text = ''
          [Nemo Action]
          Active=true
          Name=Compress
          Comment=Compress %N
          Exec=${pkgs.gnome.file-roller}/bin/file-roller --notify --default-dir=%P --add %F
          Icon-Name=gnome-mime-application-x-compress
          Selection=Any
          Extensions=any;
          Quote=double
        '';
      };
    };
  };
}
