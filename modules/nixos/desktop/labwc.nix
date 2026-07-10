{
  config,
  lib,
  flake,
  perSystem,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) toLabwcXml;
  cfg = config.desktop;
  up = perSystem.nixpkgs-unstable;
in
{
  config = mkIf cfg.enable {

    hjem.users.christoph.rum.programs.fuzzel = {
      enable = true;
      package = up.fuzzel;
      settings = {
        main = {
          font = "FiraCode Nerd Font:size=12";
          lines = 15;
          prompt = "❯";
          password-character = "●";
          show-actions = false;
        };
        colors = {
          background = "2e3440dd";
          text = "d8dee9ff";
          match = "88c0d0ff";
          selection = "3b4252ff";
          selection-text = "eceff4ff";
          border = "88c0d0ff";
        };
        border = {
          width = 2;
          radius = 8;
        };
      };
    };

    home.files.".config/labwc/rc.xml" = {
      generator = flake.lib.toLabwcXml;
      value = {
        desktops = {
          _attrs = {
            number = 6;
            popupTime = 500;
          };
        };

        placement = {
          _attrs = {
            policy = "automatic";
          };
        };

        windowSnapEdgeGap = 0;

        focus = {
          followMouse = "no";
          focusOnClick = "yes";
          raiseOnFocus = "yes";
        };

        resistance = {
          _attrs = {
            screenEdge = 20;
          };
        };

        snapping = {
          enabled = "yes";
          edgeGap = 0;
        };

        keyboard = {
          default = { };
          numlock = "yes";

          keybind = [
            # Volume
            {
              _attrs.key = "XF86_AudioLowerVolume";
              action._attrs = {
                name = "Execute";
                command = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
              };
            }
            {
              _attrs.key = "XF86_AudioRaiseVolume";
              action._attrs = {
                name = "Execute";
                command = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
              };
            }
            {
              _attrs.key = "XF86_AudioMute";
              action._attrs = {
                name = "Execute";
                command = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
              };
            }
            {
              _attrs.key = "XF86_AudioMicMute";
              action._attrs = {
                name = "Execute";
                command = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
              };
            }
            # Brightness
            {
              _attrs.key = "XF86_MonBrightnessDown";
              action._attrs = {
                name = "Execute";
                command = "brightnessctl set 5%-";
              };
            }
            {
              _attrs.key = "XF86_MonBrightnessUp";
              action._attrs = {
                name = "Execute";
                command = "brightnessctl set 5%+";
              };
            }
            # Terminal
            {
              _attrs.key = "W-Return";
              action._attrs = {
                name = "Execute";
                command = "ghostty";
              };
            }
            {
              _attrs.key = "W-S-Return";
              action._attrs = {
                name = "Execute";
                command = "ghostty --working-directory=~";
              };
            }
            # Launcher
            {
              _attrs.key = "W-d";
              action._attrs = {
                name = "Execute";
                command = "fuzzel";
              };
            }
            {
              _attrs.key = "W-S-d";
              action._attrs = {
                name = "Execute";
                command = "fuzzel --dmenu";
              };
            }
            # Close window
            { _attrs.key = "W-q"; action._attrs.name = "Close"; }
            { _attrs.key = "A-F4"; action._attrs.name = "Close"; }
            # Fullscreen
            {
              _attrs.key = "W-f";
              action._attrs.name = "ToggleFullscreen";
            }
            # Maximize
            {
              _attrs.key = "W-m";
              action._attrs.name = "ToggleMaximize";
            }
            # Minimize
            {
              _attrs.key = "W-n";
              action._attrs.name = "Iconify";
            }
            # Toggle always-on-top
            {
              _attrs.key = "W-t";
              action._attrs.name = "ToggleAlwaysOnTop";
            }
            # Window switcher
            {
              _attrs.key = "A-Tab";
              action._attrs.name = "NextWindow";
            }
            {
              _attrs.key = "A-S-Tab";
              action._attrs.name = "PreviousWindow";
            }
            {
              _attrs.key = "W-Tab";
              action._attrs.name = "NextWindow";
            }
            {
              _attrs.key = "W-S-Tab";
              action._attrs.name = "PreviousWindow";
            }
            # ponytail: FocusTo unsupported in labwc, removed directional focus keybinds
            # Move window directional
            {
              _attrs.key = "W-S-h";
              action._attrs = { name = "MoveToEdge"; direction = "left"; };
            }
            {
              _attrs.key = "W-S-j";
              action._attrs = { name = "MoveToEdge"; direction = "down"; };
            }
            {
              _attrs.key = "W-S-k";
              action._attrs = { name = "MoveToEdge"; direction = "up"; };
            }
            {
              _attrs.key = "W-S-l";
              action._attrs = { name = "MoveToEdge"; direction = "right"; };
            }
            # Workspace switching
            { _attrs.key = "W-1"; action._attrs = { name = "GoToDesktop"; to = "1"; }; }
            { _attrs.key = "W-2"; action._attrs = { name = "GoToDesktop"; to = "2"; }; }
            { _attrs.key = "W-3"; action._attrs = { name = "GoToDesktop"; to = "3"; }; }
            { _attrs.key = "W-4"; action._attrs = { name = "GoToDesktop"; to = "4"; }; }
            { _attrs.key = "W-5"; action._attrs = { name = "GoToDesktop"; to = "5"; }; }
            { _attrs.key = "W-6"; action._attrs = { name = "GoToDesktop"; to = "6"; }; }
            # Move window to workspace
            {
              _attrs.key = "W-S-1";
              action = [
                { _attrs.name = "SendToDesktop"; to = "1"; }
                { _attrs.name = "GoToDesktop"; to = "1"; }
              ];
            }
            {
              _attrs.key = "W-S-2";
              action = [
                { _attrs.name = "SendToDesktop"; to = "2"; }
                { _attrs.name = "GoToDesktop"; to = "2"; }
              ];
            }
            {
              _attrs.key = "W-S-3";
              action = [
                { _attrs.name = "SendToDesktop"; to = "3"; }
                { _attrs.name = "GoToDesktop"; to = "3"; }
              ];
            }
            {
              _attrs.key = "W-S-4";
              action = [
                { _attrs.name = "SendToDesktop"; to = "4"; }
                { _attrs.name = "GoToDesktop"; to = "4"; }
              ];
            }
            {
              _attrs.key = "W-S-5";
              action = [
                { _attrs.name = "SendToDesktop"; to = "5"; }
                { _attrs.name = "GoToDesktop"; to = "5"; }
              ];
            }
            {
              _attrs.key = "W-S-6";
              action = [
                { _attrs.name = "SendToDesktop"; to = "6"; }
                { _attrs.name = "GoToDesktop"; to = "6"; }
              ];
            }
            # Cycle workspaces
            {
              _attrs.key = "W-period";
              action._attrs = { name = "GoToDesktop"; to = "next"; };
            }
            {
              _attrs.key = "W-comma";
              action._attrs = { name = "GoToDesktop"; to = "previous"; };
            }
            # Tiling / resize
            {
              _attrs.key = "W-e";
              action._attrs.name = "ToggleMaximize";
            }
            {
              _attrs.key = "W-bracketleft";
              action = [
                { _attrs.name = "MoveToEdge"; direction = "left"; }
                { _attrs.name = "ResizeTo"; width = "50%"; }
              ];
            }
            {
              _attrs.key = "W-bracketright";
              action = [
                { _attrs.name = "MoveToEdge"; direction = "right"; }
                { _attrs.name = "ResizeTo"; width = "50%"; }
              ];
            }
            # Screenshot
            {
              _attrs.key = "Print";
              action._attrs = { name = "Execute"; command = "grim"; };
            }
            {
              _attrs.key = "S-Print";
              action._attrs = { name = "Execute"; command = "grim -g '$(slurp)'"; };
            }
            # Exit / Reconfig
            {
              _attrs.key = "W-A-Escape";
              action._attrs.name = "Exit";
            }
            {
              _attrs.key = "W-S-r";
              action._attrs.name = "Reconfigure";
            }
          ];
        };

        mouse = {
          default = { };

          context = [
            # Root menu (right-click on desktop)
            {
              _attrs.name = "Root";
              mousebind = {
                _attrs = { button = "Right"; action = "Press"; };
                action._attrs = { name = "ShowMenu"; menu = "root-menu"; };
              };
            }
            # TitleBar: left button → focus/raise/move/doubleclick=maximize
            {
              _attrs.name = "TitleBar";
              mousebind = [
                {
                  _attrs = { button = "Left"; action = "Press"; };
                  action = [
                    { _attrs.name = "Focus"; }
                    { _attrs.name = "Raise"; }
                  ];
                }
                {
                  _attrs = { button = "Left"; action = "Drag"; };
                  action._attrs.name = "Move";
                }
                {
                  _attrs = { button = "Left"; action = "DoubleClick"; };
                  action._attrs.name = "ToggleMaximize";
                }
                {
                  _attrs = { button = "Right"; action = "Press"; };
                  action = [
                    { _attrs.name = "Focus"; }
                    { _attrs.name = "Raise"; }
                  ];
                }
                {
                  _attrs = { button = "Right"; action = "Drag"; };
                  action._attrs.name = "Resize";
                }
              ];
            }
            # Edge resize handles
            { _attrs.name = "Top";
              mousebind._attrs = { button = "Left"; action = "Drag"; };
              mousebind.action._attrs.name = "Resize";
            }
            { _attrs.name = "Bottom";
              mousebind._attrs = { button = "Left"; action = "Drag"; };
              mousebind.action._attrs.name = "Resize";
            }
            { _attrs.name = "Left";
              mousebind._attrs = { button = "Left"; action = "Drag"; };
              mousebind.action._attrs.name = "Resize";
            }
            { _attrs.name = "Right";
              mousebind._attrs = { button = "Left"; action = "Drag"; };
              mousebind.action._attrs.name = "Resize";
            }
            { _attrs.name = "TLCorner";
              mousebind._attrs = { button = "Left"; action = "Drag"; };
              mousebind.action._attrs.name = "Resize";
            }
            { _attrs.name = "TRCorner";
              mousebind._attrs = { button = "Left"; action = "Drag"; };
              mousebind.action._attrs.name = "Resize";
            }
            { _attrs.name = "BLCorner";
              mousebind._attrs = { button = "Left"; action = "Drag"; };
              mousebind.action._attrs.name = "Resize";
            }
            { _attrs.name = "BRCorner";
              mousebind._attrs = { button = "Left"; action = "Drag"; };
              mousebind.action._attrs.name = "Resize";
            }
          ];
        };

        theme = {
          name = "Nordic";
          cornerRadius = 6;
          dropShadows = "yes";
          font = [
            { _attrs = { place = "ActiveWindow"; name = "Sans"; size = 10; }; }
            { _attrs = { place = "MenuItem"; name = "Sans"; size = 10; }; }
            { _attrs = { place = "OSD"; name = "Sans"; size = 10; }; }
            { _attrs = { place = "WindowTitle"; name = "Sans"; size = 10; }; }
          ];
        };

        osd = {
          enabled = "yes";
          showWorkspaceSwitcher = "yes";
          showWindowSwitcher = "yes";
        };

        windowRules = {
          windowRule = [
            {
              _attrs = { identifier = "ghostty"; title = "*"; };
              skipWindowSwitcher = "no";
            }
            {
              _attrs = { identifier = "fuzzel"; title = "*"; };
              skipWindowSwitcher = "yes";
              skipTaskbar = "yes";
              decorations = "no";
            }
          ];
        };

        libinput = {
          device = {
            _attrs.category = "default";
            naturalScroll = "yes";
            leftHanded = "no";
            pointerSpeed = 0;
            accelProfile = "adaptive";
            tapToClick = "yes";
            tapButtonMap = "lrm";
            disableWhileTyping = "yes";
          };
        };
      };
    };

    hjem.users.christoph.files.".config/labwc/menu.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>

      <labwc_menu>
        <menu id="root-menu" label="Root">
          <item label="Ghostty">
            <action name="Execute" command="ghostty" />
          </item>
          <item label="Fuzzel (Launcher)">
            <action name="Execute" command="fuzzel" />
          </item>
          <item label="File Manager">
            <action name="Execute" command="pcmanfm" />
          </item>
          <separator />
          <item label="Reconfigure">
            <action name="Reconfigure" />
          </item>
          <item label="Exit Labwc">
            <action name="Exit" />
          </item>
        </menu>
      </labwc_menu>
    '';

    hjem.users.christoph.files.".config/labwc/autostart".text = ''
      #!/usr/bin/env bash
      #
      # Labwc autostart
      # Managed by hjem / nixcfg — do not edit manually
      #
      # Services (waybar, swaybg, swayidle) are managed via systemd user services.
      # No manual startup needed unless you want additional user-level processes.
    '';

    # Ensure autostart is executable
    hjem.users.christoph.files.".config/labwc/autostart".executable = true;

  };
}
