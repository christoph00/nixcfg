{
  pkgs,
  config,
  lib,
  ...
}: let

gtklock-blur = pkgs.writeShellScriptBin "gtklock-blur" ''
      outdir="/tmp/gtklock"
      outputs="(eDP-1)"

      ${pkgs.coreutils}/bin/mkdir -p $outdir

      convertImg() {
        ${pkgs.grim}/bin/grim -o $o "$outdir/$o.png"
        size=$(${pkgs.imagemagick}/bin/identify -format "%wx%h" "$outdir/$o.png")

        ${pkgs.imagemagick}/bin/convert "$outdir/$o.png" -filter Gaussian \
          -resize 50% -define filter:sigma=3 -resize 200% "$outdir/$o.png"

        ${pkgs.imagemagick}/bin/magick -size "$size" radial-gradient:black-white \
          -contrast-stretch 3%x0% "$outdir/$o-gradient.png"

        ${pkgs.imagemagick}/bin/convert "$outdir/$o.png" "$outdir/$o-gradient.png" \
          -compose multiply -composite "$outdir/$o.png"

        ${pkgs.coreutils}/bin/rm "$outdir/$o-gradient.png"
      }

      for o in ''${outputs[@]}; do
        convertImg &
      done

      wait

      ${pkgs.gtklock}/bin/gtklock -d
    '';
in {
  services.swayidle = {
    enable = true;
     events = [
       {
         event = "before-sleep";
         command = "${pkgs.systemd}/bin/loginctl lock-session";
       }
       {
        event = "lock";
         command = "${gtklock-blur}";
       }
     ];
    timeouts = [
      {
        timeout = 300;
        command = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch dpms off";
        resumeCommand = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch dpms on";
      }
    ];
  };
  systemd.user.services.swayidle.Install.WantedBy = lib.mkForce ["hyprland-session.target"];
}
