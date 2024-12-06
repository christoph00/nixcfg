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
  cfg = config.internal.services.mqtt;

in

{

  options.internal.services.mqtt = {
    enable = mkBoolOpt config.internal.isSmartHome "Enable MQTT Broker.";
    settings = mkOption {
      type = types.attrs;
      default = {
        listeners = [
          {
            type = "tcp";
            id = "tcp1";
            address = ":1883";
          }
        ];
        hooks = {
          auth.allow_all = true;
        };
        options = {
          inline_client = true;
        };
      };
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [ mqttui ];

    #environment.etc."mosquitto/mosquitto-acl-0.conf".enable = false;

    internal.services.agent.broker.host = "127.0.0.1";

    services.mosquitto = {
      enable = true;
      persistence = true;
      listeners = [
        {
          settings.allow_anonymous = true;
          acl = [ "topic readwrite #" ];
          users = {
            ha = {
              acl = [ "readwrite #" ];
              hashedPassword = "$7$101$GyuMMbkoRFjB8z8R$Xt6dXXBHYQ+Xz8jModT9+bsZluCtWw4aLjtUH1ygzYga9/c6j8WDbyfAV/TAhjpBxdx41SJmUAvlMegvZ0C0zw==";
            };
            robot = {
              acl = [ "readwrite #" ];
              hashedPassword = "$7$101$kcTDlpmOtQEBLOTa$hn8c6AJ9I+j927e/t7CaH9v349bbd8JwuIw5EI4prnIimvX6rQMMlndbhStzE6/NlJ2QPhNVGJAe5AOHyqEmLQ==";
            };
            agent = {
              acl = [ "readwrite #" ];
              hashedPassword = "$7$101$H99cwUp4aL5ePW3t$YN8Votxip8OpX0dMVJv34hefj8RrHq2l64SwEH1oUr7bFT1eX8R4vthTnTGBfHgfR9r9aMPfMdPgun8RkHMMGw==";
            };
          };
        }
      ];
    };

  };

}
