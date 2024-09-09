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
  cfg = config.internal.services.novnc;
in

{

  options.internal.services.novnc = {
    enable = mkBoolOpt config.internal.graphical.desktop.headless.enable "Enable noVNC Service.";
  };

  config = mkIf cfg.enable {

    services.nginx.enable = true;

    services.nginx.virtualHosts."_" = {
      enableACME = false;
      listen = [
        {
          addr = "0.0.0.0";
          port = 8181;
          ssl = false;
        }
      ];
      locations = {
        "/websockify" = {
          proxyWebsockets = true;
          proxyPass = "http://127.0.0.1:5921";
          extraConfig = ''
            proxy_read_timeout 61s;
            proxy_buffering off;
          '';
        };

        "/" = {
          root = "${pkgs.novnc}/share/webapps/novnc";
          index = "vnc.html";
        };
      };
    };

    systemd.services.websockify = {
      description = "Websockify";
      wantedBy = [ "default.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.python3Packages.websockify}/bin/websockify 5921 127.0.0.1:5900";
        Restart = "always";
      };
    };

  };

}
