{
  flake,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with flake.lib;
let
  cfg = config.shell;
in
{
  imports = [
    ./neovim
    ./devtools.nix
    ./office.nix
  ];
  options.shell = with types; {
    enable = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    environment.enableAllTerminfo = true;
    environment.binsh = "${pkgs.dash}/bin/dash";
    programs.direnv = enabled;
    programs.git = enabled;
    environment.systemPackages = with pkgs; [
      htop
      wget
      ripgrep
      unzip
      pciutils
      jq
      jc
      killall
      rsync
      usbutils
      uutils-coreutils-noprefix
      dnsutils
      fzf
      lsd
      zoxide
    ];
    environment.shells = with pkgs; [
      # nushell
      # dash
    ];

    programs.bash = {
      enable = true;
      enableCompletion = true;
      promptInit = ''
        eval "$(${pkgs.starship}/bin/starship init bash)"
      '';
      interactiveShellInit = ''
        eval "$(${pkgs.direnv}/bin/direnv hook bash)"
      '';
      shellAliases = {
        z = "zoxide";
        vi = "nvim";
        ls = "lsd";
        ll = "lsd -l";
        la = "lsd -a";
        lal = "lsd -al";
      };
    };

    home.rum.programs.nushell = {
      enable = false;
      settings = {
        edit_mode = "vi";
        buffer_editor = "nvim";
        show_banner = false;
        history = {
          file_format = "sqlite";
          max_size = "1_000_000";
          sync_on_enter = true;
          isolation = false;
        };
        table = {
          mode = "light";
          index_mode = "auto";
        };
      };
      aliases = {
        ll = "ls -l";
        # dotfiles = "git --git-dir=($env.HOME | path join Code dotfiles) --work-tree=$env.HOME";
      };
      # plugins = with pkgs.nushellPlugins; [
      #  units
      #  formats
      #  query
      # ];
      extraConfig = ''
        	def dotfiles [...args] {
            		git --git-dir=($env.HOME | path join Code dotfiles) --work-tree=$env.HOME ...$args
        	}



                  let extra_paths = [
             $"($env.HOME)/.local/bin"
               $"($env.HOME)/.bun/bin"
                 $"($env.HOME)/.cargo/bin"
            $'(npm config get prefix)/bin',
                 $"($env.HOME)/.config/composer/vendor/bin"
            ]
            let valid_paths = ($extra_paths | where { |p| $p | path exists })
            $env.PATH = ($env.PATH | split row (char esep) | append $valid_paths | uniq)
            $env.GH_NPM_TOKEN = ^"gh" auth token


                  const profile_file = $"($nu.home-path)/.profile.nu"

                  const file_to_source = if ($profile_file | path exists) {
                      $profile_file
                  } else {
                      null
                  }

                  source $file_to_source
      '';

    };

  };
}
