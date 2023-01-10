{
  pkgs,
  config,
  lib,
  ...
}:
with lib; {
  services.code-server = {
    enable = true;
    extensions = mkDefault config.programs.vscode.extensions;
    auth = mkDefault "none";
    bindAddr = mkDefault "0.0.0.0:8080";
    userSettings = mkMerge [
      config.programs.vscode.userSettings
      {
        "terminal.integrated.shell.linux" = "${pkgs.fish}/bin/fish";
        "breadcrumbs.enabled" = true;
      }
    ];
  };
}
