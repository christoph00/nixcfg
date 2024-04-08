{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.services.code-server;
in {
  options.chr.services.code-server = with types; {
    enable = mkBoolOpt false "Enable Code-Server Service.";
  };
  config = mkIf cfg.enable {
    services.openvscode-server = {
      enable = true;
      user = "christoph";
      group = "christoph";

      extraPackages = with pkgs; [git nixd nixfmt alejandra];
      host = "0.0.0.0";
      socketPath = "/run/openvscode/socket";
      serverDataDir = "${config.users.users.christoph.home}/.config/openvscode-server";
      telemetryLevel = "off";
      use-immutable-settings = true;
      withoutConnectionToken = false;
      settings = {
        "[go]" = {"editor.defaultFormatter" = "golang.go";};
        "[javascript]" = {
          "editor.defaultFormatter" = "dbaeumer.vscode-eslint";
        };
        "[javascriptreact]" = {
          "editor.defaultFormatter" = "dbaeumer.vscode-eslint";
        };
        "[json]" = {
          "editor.defaultFormatter" = "vscode.json-language-features";
        };
        "[jsonc]" = {
          "editor.defaultFormatter" = "vscode.json-language-features";
        };
        "[latex]" = {"editor.defaultFormatter" = "James-Yu.latex-workshop";};
        "[nix]" = {"editor.defaultFormatter" = "jnoortheen.nix-ide";};
        "[typescript]" = {
          "editor.defaultFormatter" = "dbaeumer.vscode-eslint";
        };
        "[typescriptreact]" = {
          "editor.defaultFormatter" = "dbaeumer.vscode-eslint";
        };
        "[xml]" = {"editor.defaultFormatter" = "redhat.vscode-xml";};
        "[yaml]" = {"editor.formatOnSave" = false;};
        "debug.javascript.autoAttachFilter" = "smart";
        "diffEditor.maxComputationTime" = 0;
        "diffEditor.wordWrap" = "off";
        "editor.bracketPairColorization.enabled" = true;
        "editor.fontFamily" = "Monospace";
        "editor.fontLigatures" = false;
        "editor.formatOnSave" = true;
        "editor.guides.bracketPairs" = "active";
        "editor.maxTokenizationLineLength" = 10000;
        "editor.minimap.enabled" = false;
        "editor.unicodeHighlight.ambiguousCharacters" = false;
        "editor.wordWrap" = "on";
        "eslint.format.enable" = true;
        "eslint.lintTask.enable" = true;
        "explorer.confirmDelete" = false;
        "explorer.confirmDragAndDrop" = false;
        "git.autofetch" = false;
        "git.confirmSync" = false;
        "git.enableSmartCommit" = true;
        "go.toolsManagement.autoUpdate" = true;
        "javascript.updateImportsOnFileMove.enabled" = "always";
        "latex-workshop.view.pdf.viewer" = "tab";

        "nixEnvSelector.nixFile" = "\${workspaceRoot}/shell.nix";
        "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
        "nix.formatterPath" = "${pkgs.nixfmt}/bin/nixfmt";
        "nix.enableLanguageServer" = true;
        "nix.serverSettings" = {
          nixd = {
            formatting.command = "${pkgs.nixfmt}/bin/nixfmt";
            options = {
              enable = true;
            };
          };
        };

        "redhat.telemetry.enabled" = false;
        "security.workspace.trust.untrustedFiles" = "open";
        "terminal.integrated.defaultProfile.linux" = "zsh";
        "terminal.integrated.fontFamily" = "Hack Nerd Font Mono";
        "terminal.integrated.defaultProfile.osx" = "zsh";
        "terminal.integrated.shellIntegration.enabled" = false;
        "typescript.updateImportsOnFileMove.enabled" = "always";
        "window.titleBarStyle" = "custom";
        "workbench.colorTheme" = "Tomorrow Night Blue";
        "workbench.iconTheme" = "material-icon-theme";
        "workbench.settings.editor" = "json";
      };
    };
    services.cloudflared.tunnels."${config.networking.hostName}" = {
      ingress = {
        "code.r505.de" = "http://127.0.0.1:${config.services.openvscode-server.port}";
      };
    };
  };
}
