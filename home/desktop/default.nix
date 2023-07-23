{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  theme-html = with config.colorscheme;
    pkgs.writeTextFile {
      name = "base16-theme";
      destination = "/share/doc/base16.html";
      text = ''
        <html>
          <head>
            <meta http-equiv="content-type" content="text/html">
            <title>Base16 ${slug}</title>
            <style type="text/css" media="screen">
              body { margin: 5% 20%; }
              .scheme, .author, pre, .block { font-family: "menlo", "consolas", monospace; }
          	  .block { display: inline-block; font-size: 13px; font-weight: bold; padding: 15px; margin: 0 5px 10px 0; }
          	  pre {
          	    font-size: 14px;
          	    padding: 10px 20px;
          	  }

              .base00-background { background-color: #${colors.base00}; }
              .base01-background { background-color: #${colors.base01}; }
              .base02-background { background-color: #${colors.base02}; }
              .base03-background { background-color: #${colors.base03}; }
              .base04-background { background-color: #${colors.base04}; }
              .base05-background { background-color: #${colors.base05}; }
              .base06-background { background-color: #${colors.base06}; }
              .base07-background { background-color: #${colors.base07}; }
              .base08-background { background-color: #${colors.base08}; }
              .base09-background { background-color: #${colors.base09}; }
              .base0A-background { background-color: #${colors.base0A}; }
              .base0B-background { background-color: #${colors.base0B}; }
              .base0C-background { background-color: #${colors.base0C}; }
              .base0D-background { background-color: #${colors.base0D}; }
              .base0E-background { background-color: #${colors.base0E}; }
              .base0F-background { background-color: #${colors.base0F}; }

              .base00 { color: #${colors.base00}; }
              .base01 { color: #${colors.base01}; }
              .base02 { color: #${colors.base02}; }
              .base03 { color: #${colors.base03}; }
              .base04 { color: #${colors.base04}; }
              .base05 { color: #${colors.base05}; }
              .base06 { color: #${colors.base06}; }
              .base07 { color: #${colors.base07}; }
              .base08 { color: #${colors.base08}; }
              .base09 { color: #${colors.base09}; }
              .base0A { color: #${colors.base0A}; }
              .base0B { color: #${colors.base0B}; }
              .base0C { color: #${colors.base0C}; }
              .base0D { color: #${colors.base0D}; }
              .base0E { color: #${colors.base0E}; }
              .base0F { color: #${colors.base0F}; }
            </style>
          </head>
          <body>

            <h1 class="scheme">Base16 ${slug}</h1>

            <div>
              <div class="block base00-background base07">00</div>
              <div class="block base01-background base07">01</div>
              <div class="block base02-background base07">02</div>
              <div class="block base03-background base07">03</div>
              <div class="block base04-background base00">04</div>
              <div class="block base05-background base00">05</div>
              <div class="block base06-background base00">06</div>
              <div class="block base07-background base00">07</div>
              <br />
              <div class="block base08-background base07">08</div>
              <div class="block base09-background base07">09</div>
              <div class="block base0A-background base07">0A</div>
              <div class="block base0B-background base07">0B</div>
              <div class="block base0C-background base07">0C</div>
              <div class="block base0D-background base07">0D</div>
              <div class="block base0E-background base07">0E</div>
              <div class="block base0F-background base07">0F</div>
            </div>

            <div>

              <pre class="base00-background base05">
        <span class="base0E">require</span> <span class="base0B">"gem"</span>

        <span class="base08">string</span> = <span class="base0B">"base16"</span>
        <span class="base08">symbol</span> = <span class="base0B">:base16</span>
        <span class="base08">fixnum</span> = <span class="base09">0</span>
        <span class="base08">float</span>  = <span class="base09">0.00</span>
        <span class="base08">array</span>  = <span class="base0A">Array</span>.<span class="base0D">new</span>
        <span class="base08">array</span>  = [<span class="base0B">'chris'</span>, <span class="base09">85</span>]
        <span class="base08">hash</span>   = {<span class="base0B">"test"</span> => <span class="base0B">"test"</span>}
        <span class="base08">regexp</span> = <span class="base0C">/[abc]/</span>

        <span class="base03"># This is a comment</span>
        <span class="base0E">class</span> <span class="base0A">Person</span>

          <span class="base0D">attr_accessor</span> <span class="base0B">:name</span>

          <span class="base0E">def</span> <span class="base0D">initialize</span>(<span class="base08">attributes</span> = {})
            <span class="base08">@name</span> = <span class="base08">attributes</span>[<span class="base0B">:name</span>]
          <span class="base0E">end</span>

          <span class="base0E">def</span> <span class="base0E">self</span>.<span class="base0D">greet</span>
            <span class="base02-background"><span class="base0B">"hello"</span></span>
          <span class="base0E">end</span>
        <span class="base0E">end</span>

        <span class="base08">person1</span> = <span class="base0A">Person</span>.<span class="base0D">new</span>(<span class="base0B">:name</span> => <span class="base0B">"Chris"</span>)
        <span class="base0D">print</span> <span class="base0A">Person</span>::<span class="base0D">greet</span>, <span class="base0B">" "</span>, <span class="base08">person1</span>.<span class="base0D">name</span>, <span class="base0B">"<span class="base09">\n</span>"</span>
        <span class="base0D">puts</span> <span class="base0B">"another </span><span class="base0F">#{</span><span class="base0A">Person</span>::<span class="base0D">greet</span><span class="base0F">}</span> <span class="base0F">#{</span><span class="base08">person1</span>.<span class="base0D">name</span><span class="base0F">}</span><span class="base0B">"</span>
              </pre>

            </div>
          </body>
        </html>
      '';
    };

  mkWallpaper = {
    scheme,
    width,
    height,
    logoScale,
  }:
    pkgs.stdenv.mkDerivation {
      name = "generated-nix-wallpaper-${scheme.slug}.png";
      src = pkgs.writeTextFile {
        name = "template.svg";
        text = ''
          <svg width="${toString width}" height="${
            toString height
          }" version="1.1" xmlns="http://www.w3.org/2000/svg">
            <rect width="${toString width}" height="${
            toString height
          }" fill="#${scheme.colors.base00}"/>
            <svg x="${toString (width / 2 - (logoScale * 50))}" y="${
            toString (height / 2 - (logoScale * 50))
          }" version="1.1" xmlns="http://www.w3.org/2000/svg">
              <g transform="scale(${toString logoScale})">
                <g transform="matrix(.19936 0 0 .19936 80.161 27.828)">
                  <path d="m-53.275 105.84-122.2-211.68 56.157-0.5268 32.624 56.869 32.856-56.565 27.902 0.011 14.291 24.69-46.81 80.49 33.229 57.826zm-142.26 92.748 244.42 0.012-27.622 48.897-65.562-0.1813 32.559 56.737-13.961 24.158-28.528 0.031-46.301-80.784-66.693-0.1359zm-9.3752-169.2-122.22 211.67-28.535-48.37 32.938-56.688-65.415-0.1717-13.942-24.169 14.237-24.721 93.111 0.2937 33.464-57.69z" fill="#${scheme.colors.base0C}"/>
                  <path d="m-97.659 193.01 122.22-211.67 28.535 48.37-32.938 56.688 65.415 0.1716 13.941 24.169-14.237 24.721-93.111-0.2937-33.464 57.69zm-9.5985-169.65-244.42-0.012 27.622-48.897 65.562 0.1813-32.559-56.737 13.961-24.158 28.528-0.031 46.301 80.784 66.693 0.1359zm-141.76 93.224 122.2 211.68-56.157 0.5268-32.624-56.869-32.856 56.565-27.902-0.011-14.291-24.69 46.81-80.49-33.229-57.826z" fill="#${scheme.colors.base0D}" style="isolation:auto;mix-blend-mode:normal"/>
                </g>
              </g>
            </svg>
          </svg>
        '';
      };
      buildInputs = with pkgs; [inkscape];
      unpackPhase = "true";
      buildPhase = ''
        inkscape --export-type="png" $src -w ${toString width} -h ${
          toString height
        } -o wallpaper.png
      '';
      installPhase = "install -Dm0644 wallpaper.png $out";
    };
  gpt4all = pkgs.makeDesktopItem {
    name = "gpt4all";
    exec = "${inputs.gpt4all.packages.x86_64-linux.default}/bin/chat";
    desktopName = "gpt4all";
  };
in {
  imports = [
    ./anyrun.nix
    ./gtk.nix
    #./plasma.nix
    ./hyprland.nix
    #./sway.nix
    #./wayvnc.nix
    #./rofi.nix
    #./xfce.nix
    #./labwc.nix
    #./river.nix
    ./idle.nix
    ./ironbar.nix
    # ./eww.nix
    #./sfwbar.nix
    # ./waybar.nix
  ];

  home.packages = with pkgs; [
    libnotify
    playerctl
    wireplumber
    wtype
    pavucontrol
    vlc

    xdg-utils
    solaar

    pciutils

    foot

    kanshi

    usbimager

    gimp-with-plugins
    inkscape

    inputs.agenix.packages.x86_64-linux.default
    inputs.deploy-rs.defaultPackage.${pkgs.system}

    themechanger

    gnome.gnome-keyring

    darktable

    nix-init

    nixd

    pcmanfm
    webcord

    theme-html
    # gpt4all
  ];

  xdg.configFile."xkb/symbols/us-german-umlaut" = {
    text = ''
      default partial alphanumeric_keys
      xkb_symbols "basic" {
      include "us(altgr-intl)"
      name[Group1] = "English (US, international with German umlaut)";
      key <AD03> { [ e, E, EuroSign, cent ] };
      key <AD07> { [ u, U, udiaeresis, Udiaeresis ] };
      key <AD09> { [ o, O, odiaeresis, Odiaeresis ] };
      key <AC01> { [ a, A, adiaeresis, Adiaeresis ] };
      key <AC02> { [ s, S, ssharp ] };
       };
    '';
  };

  colorscheme = inputs.nix-colors.colorSchemes.tokyo-night-light;
  wallpaper = lib.mkDefault (mkWallpaper
    {
      scheme = config.colorscheme;
      width = 1920;
      height = 1080;
      logoScale = 4;
    });
  xdg.dataFile."colorscheme".text = config.colorscheme.slug;
  xdg.dataFile."wallpaper.png".source = config.wallpaper;

  home.sessionVariables = {
    #BROWSER = "firefox";
    #TERMINAL = "footclient";
    NIXPKGS_ALLOW_UNFREE = 1;
    NIXOS_OZONE_WL = 1;
  };

  #xdg.mimeApps.enable = true;
  #xdg.mimeApps.associations.added = associations;
  #xdg.mimeApps.defaultApplications = associations;

  fontProfiles = {
    enable = true;
    monospace = {
      family = "Agave Nerd Font";
      package = pkgs.nerdfonts.override {fonts = ["Agave"];};
    };
    regular = {
      family = "Fira Sans";
      package = pkgs.fira;
    };
  };

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "true";
    QT_QPA_PLATFORM = "wayland";
    LIBSEAT_BACKEND = "logind";
    GTK_THEME = "${config.gtk.theme.name}";
    XCURSOR_THEME = "${config.gtk.cursorTheme.name}";
    XCURSOR_SIZE = "${toString config.gtk.cursorTheme.size}";
  };

  dconf.enable = true;
  services.gnome-keyring = {
    enable = true;
    components = ["ssh" "secrets"];
  };
  services.wlsunset = {
    enable = true;
    latitude = "52.3";
    longitude = "9.7";
  };
}
