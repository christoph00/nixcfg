{pkgs, ...}: {
  services.emacs = {
    enable = true;
  };
  programs.emacs = {
    enable = true;

    package = pkgs.emacs-gtk;

    init = {
      enable = true;

      packageQuickstart = false;
      recommendedGcSettings = true;
      usePackageVerbose = false;

      earlyInit = ''
        ;; Disable some GUI distractions. We set these manually to avoid starting
        ;; the corresponding minor modes.
        (push '(menu-bar-lines . 0) default-frame-alist)
        (push '(tool-bar-lines . nil) default-frame-alist)
        (push '(vertical-scroll-bars . nil) default-frame-alist)

        ;; Set up fonts early.
        (set-face-attribute 'default
                            nil
                            :height 105
                            :family "Source Code Pro")
        (set-face-attribute 'fixed-pitch nil :font "Source Code Pro" :height 100)
        (set-face-attribute '
         variable-pitch nil :font "Cantarell" :height 150 :weight 'regular)
      '';
      prelude = ''
        ;; Disable startup message.
        (setq inhibit-startup-screen t
              inhibit-startup-echo-area-message (user-login-name))

        (setq initial-major-mode 'fundamental-mode
              initial-scratch-message nil)

        (setq custom-file (locate-user-emacs-file "custom.el"))

         ;; Backups
        (setq
          backup-by-copying t      ; don't clobber symlinks
          backup-directory-alist
          '(("." . "~/.saves/"))    ; don't litter my fs tree
          delete-old-versions t
          kept-new-versions 6
          kept-old-versions 2
          version-control t
          global-visual-line-mode t)

        ;; Cleaning up some visual mess
        (tool-bar-mode 0)
        (scroll-bar-mode 0)

        ;; Safe themes
        (setq custom-safe-themes t)
      '';
      usePackage = {
        crux = {
          enable = true;
          bind = {
            "C-c d" = "crux-duplicate-current-line-or-region";
            "C-c M-d" = "crux-duplicate-and-comment-current-line-or-region";

            # "C-k" = "crux-smart-kill-line";
            "C-k" = "crux-kill-and-join-forward";

            "C-S-RET" = "crux-smart-open-line-above";
            "S-RET" = "crux-smart-open-line";
            "C-x 4 t" = "crux-transpose-windows";
            "C-c D" = "crux-delete-file-and-buffer";
            # "C-c r" = "crux-rename-file-and-buffer";
            "C-c TAB" = "crux-indent-rigidly-and-copy-to-clipboard";
            # "Super-j" = "crux-top-join-line";
            # "C-Backspace" = "crux-kill-line-backwards";
            "M-o" = "crux-other-window-or-switch-buffer";
          };
        };

        all-the-icons.enable = true;

        ripgrep.enable = true;

        nix-mode.enable = true;

        modus-themes.enable = true;

        systemd = {
          enable = true;
          defer = true;
        };

        eglot = {
          enable = true;
          config = ''
            (add-to-list 'eglot-server-programs '(nix-mode . ("nixd")))
          '';
          hook = ["(nix-mode . eglot-ensure)"];
        };

        which-key = {
          enable = true;
          command = ["which-key-mode"];
          diminish = ["which-key-mode"];
          defer = 2;
          config = "(which-key-mode)";
        };

        ivy = {
          enable = true;
          demand = true;
          diminish = ["ivy-mode"];
          command = ["ivy-mode"];
          config = ''
            (setq ivy-use-virtual-buffers t
                  ivy-count-format "%d/%d "
                  ivy-virtual-abbreviate 'full)

            (ivy-mode 1)
          '';
        };

        ivy-hydra = {
          enable = true;
          defer = true;
          after = ["ivy" "hydra"];
        };

        ivy-xref = {
          enable = true;
          after = ["ivy" "xref"];
          command = ["ivy-xref-show-xrefs"];
          config = ''
            (setq xref-show-xrefs-function #'ivy-xref-show-xrefs)
          '';
        };

        swiper = {
          enable = true;
          command = ["swiper" "swiper-all" "swiper-isearch"];
          bind = {
            "C-s" = "swiper-isearch";
          };
        };

        # Lets counsel do prioritization. A fork of smex.
        amx = {
          enable = true;
          command = ["amx-initialize"];
        };

        counsel = {
          enable = true;
          bind = {
            "C-x C-d" = "counsel-dired-jump";
            "C-x C-f" = "counsel-find-file";
            "C-x C-M-f" = "counsel-fzf";
            "C-x C-r" = "counsel-recentf";
            "C-x C-y" = "counsel-yank-pop";
            "M-x" = "counsel-M-x";
            "C-c g" = "counsel-git-grep";
          };
          diminish = ["counsel-mode"];
          config = let
            fd = "${pkgs.fd}/bin/fd";
            fzf = "${pkgs.fzf}/bin/fzf";
          in ''
            (setq counsel-fzf-cmd "${fd} --type f | ${fzf} -f \"%s\"")
          '';
        };
      };
    };
  };
}
