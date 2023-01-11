{
  config,
  pkgs,
  makeBinPath,
  ...
}: {
  systemd.services.code-tunnel = {
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    description = "VSCode Tunnel";
    serviceConfig = {
      TimeoutStartSec = 0;
      Type = "notify";
      ExecStart = "${pkgs.code-cli}/bin/code-cli tunnel";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
  systemd.services.code-tunnel-autofix = {
    wantedBy = ["code-tunnel.service"];
    name = "code-tunnel-autofix";    
    serviceConfig = {
      ExecStart = "${pkgs.writeShellScript "${name}.sh" ''
        set -euo pipefail
        PATH=${makeBinPath (with pkgs; [ coreutils findutils inotify-tools ])}
        bin_dir=~/.vscode-cli/code-stable/bin
        # Fix any existing symlinks before we enter the inotify loop.
        if [[ -e $bin_dir ]]; then
          find "$bin_dir" -mindepth 2 -maxdepth 2 -name node -exec ln -sfT ${pkgs.nodejs-16_x}/bin/node {} \;
          find "$bin_dir" -path '*/@vscode/ripgrep/bin/rg' -exec ln -sfT ${pkgs.ripgrep}/bin/rg {} \;
        else
          mkdir -p "$bin_dir"
        fi
        while IFS=: read -r bin_dir event; do
          # A new version of the VS Code Server is being created.
          if [[ $event == 'CREATE,ISDIR' ]]; then
            # Create a trigger to know when their node is being created and replace it for our symlink.
            touch "$bin_dir/node"
            inotifywait -qq -e DELETE_SELF "$bin_dir/node"
            ln -sfT ${pkgs.nodejs-16_x}/bin/node "$bin_dir/node"
            ln -sfT ${pkgs.ripgrep}/bin/rg "$bin_dir/node_modules/@vscode/ripgrep/bin/rg"
          # The monitored directory is deleted, e.g. when "Uninstall VS Code Server from Host" has been run.
          elif [[ $event == DELETE_SELF ]]; then
            # See the comments above Restart in the service config.
            exit 0
          fi
        done < <(inotifywait -q -m -e CREATE,ISDIR -e DELETE_SELF --format '%w%f:%e' "$bin_dir")
      ''}";
        };
  };
}
