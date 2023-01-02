{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.conf.desktop.wofi;
  wofi-css = with config.scheme.withHashtag;
    pkgs.writeText "style.css" ''

                  * {
                    transition: none;
                    box-shadow: none;
                    font-family: ${config.conf.fonts.monospace.name};
                  }

          window {
                background-color: ${base00};
          }

          #input {
          margin: 5px;
          border-radius: 0px;
          border: none;
          border-bottom: 3px solid black;
          background-color: ${base01};
          color: white;
      }

      #inner-box {
          background-color: ${base01};

      }

      #outer-box {
          margin: 5px;
          padding:20px;
          background-color: ${base00};
      }

      #scroll {
      }

      #text {
      padding: 5px;
      color: white;
      }


      #entry:selected {
          background-color: ${base04};
      }

      #text:selected {
      }

    '';
in {
  options.conf.desktop.wofi.enable = lib.mkEnableOption "wofi";

  config.home-manager.users.${config.conf.users.user} = lib.mkIf cfg.enable {
    xdg.configFile."wofi/config".text = ''
      image_size=48
      columns=3
      allow_images=true
      insensitive=true

      run-always_parse_args=true
      run-cache_file=/dev/null
      run-exec_search=true
    '';

    xdg.configFile."wofi/style.css".source = wofi-css;
  };
}
