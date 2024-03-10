{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.desktop.wayfire;
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
in {
  options.chr.desktop.wayfire = with types; {
    enable = mkBoolOpt config.chr.desktop.enable "Whether or not enable Wayfire Desktop.";
    scale = lib.mkOption {
      type = lib.types.str;
      default = "1";
    };
    layout = lib.mkOption {
      type = lib.types.str;
      default = "de";
    };
  };

  config = mkIf cfg.enable {
    chr.desktop = {
      ags.enable = true;
      anyrun.enable = true;
    };

    programs.wayfire = {
      enable = true;
      plugins = with pkgs.wayfirePlugins; [
        wcm
        wf-shell
        wayfire-plugins-extra
      ];
    };
    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };
    services.greetd = {
      enable = true;
      settings = {
        # default_session.command = ''
        #   ${pkgs.greetd.tuigreet}/bin/tuigreet --remember --user-menu --asterisks --time --greeting "Welcome to NixOS" --cmd ${plasma}/bin/plasma'';
        initial_session = {
          command = "wayfire";
          user = config.chr.user.name;
        };
      };
    };
    programs.regreet.enable = true;
    environment.persistence."${config.chr.system.persist.stateDir}".directories = lib.mkIf config.chr.system.persist.enable ["/var/cache/regreet"];

    security = {
      polkit.enable = true;
      pam.services.ags = {};
    };

    environment.systemPackages = with pkgs.gnome; [
      pkgs.loupe
      adwaita-icon-theme
      nautilus
      baobab
      gnome-calendar
      gnome-boxes
      gnome-system-monitor
      gnome-control-center
      gnome-weather
      gnome-calculator
      gnome-clocks
    ];

    systemd = {
      user.services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = ["graphical-session.target"];
        wants = ["graphical-session.target"];
        after = ["graphical-session.target"];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };

    environment.variables.NIXOS_OZONE_WL = "1";

    services = {
      gvfs.enable = true;
      devmon.enable = true;
      udisks2.enable = true;
      upower.enable = true;
      accounts-daemon.enable = true;
      gnome = {
        evolution-data-server.enable = true;
        glib-networking.enable = true;
        gnome-keyring.enable = true;
        gnome-online-accounts.enable = true;
      };
    };

    chr.home.extraOptions = {
      xdg.configFile."hyprshade/config.toml".text = ''
        [[shades]]
        name = blue-light-filter
        start_time = 19:00:00
        end_time = 08:00:00
      '';

      xdg.configFile."hypr/shaders/blue-light-filter.glsl" = {
        # https://github.com/hyprwm/Hyprland/issues/1140#issuecomment-1335128437
        text = ''
          precision mediump float;
          varying vec2 v_texcoord;
          uniform sampler2D tex;

          const float temperature = 2600.0;
          const float temperatureStrength = 1.0;

          #define WithQuickAndDirtyLuminancePreservation
          const float LuminancePreservationFactor = 1.0;

          // function from https://www.shadertoy.com/view/4sc3D7
          // valid from 1000 to 40000 K (and additionally 0 for pure full white)
          vec3 colorTemperatureToRGB(const in float temperature){
              // values from: http://blenderartists.org/forum/showthread.php?270332-OSL-Goodness&p=2268693&viewfull=1#post2268693
              mat3 m = (temperature <= 6500.0) ? mat3(vec3(0.0, -2902.1955373783176, -8257.7997278925690),
                                                      vec3(0.0, 1669.5803561666639, 2575.2827530017594),
                                                      vec3(1.0, 1.3302673723350029, 1.8993753891711275)) :
                                                 mat3(vec3(1745.0425298314172, 1216.6168361476490, -8257.7997278925690),
                                                      vec3(-2666.3474220535695, -2173.1012343082230, 2575.2827530017594),
                                                      vec3(0.55995389139931482, 0.70381203140554553, 1.8993753891711275));
              return mix(
                  clamp(vec3(m[0] / (vec3(clamp(temperature, 1000.0, 40000.0)) + m[1]) + m[2]), vec3(0.0), vec3(1.0)),
                  vec3(1.0),
                  smoothstep(1000.0, 0.0, temperature)
              );
          }

          void main() {
              vec4 pixColor = texture2D(tex, v_texcoord);

              // RGB
              vec3 color = vec3(pixColor[0], pixColor[1], pixColor[2]);

          #ifdef WithQuickAndDirtyLuminancePreservation
              color *= mix(1.0,
                           dot(color, vec3(0.2126, 0.7152, 0.0722)) / max(dot(color, vec3(0.2126, 0.7152, 0.0722)), 1e-5),
                           LuminancePreservationFactor);
          #endif

              color = mix(color, color * colorTemperatureToRGB(temperature), temperatureStrength);

              vec4 outCol = vec4(color, pixColor[3]);

              gl_FragColor = outCol;
          }
        '';
      };
    };
  };
}
