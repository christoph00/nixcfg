{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib) mkIf;

in
{

  config = mkIf config.services.mosquitto.enable {

    environment.systemPackages = with pkgs; [ mqttui ];

    services.mosquitto = {
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
