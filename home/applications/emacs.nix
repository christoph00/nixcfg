{
  pkgs,
  lib,
  ...
}: {
  services.emacs = {
    enable = true;
  };
  programs.emacs = {
    enable = true;
    package = lib.mkForce (pkgs.emacs-pgtk.override {
      withTreeSitter = true;
      withNativeCompilation = true;
      withImageMagick = true;
      withSystemd = true;      
    });

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

         (setq ok/font-alist
             	 '((jetbrains-mono . (:font   "JetBrains Mono Nerd Font"
        		   :height 140))
        (iosevka        . (:font   "Iosevka"
        		   :height 160))))

                (setq ok/current-font 'jetbrains-mono)

                (defun ok/switch-font (font)
                "Select one of the fonts configured in 'ok/font-alist' as the face-font."
                (interactive
                (list (intern (completing-read "Font: " (mapcar #'car (copy-alist ok/font-alist))))))
                ;; If the selected font is not the currently active font, switch.
                (let* ((attrs (alist-get font ok/font-alist))
               (font (plist-get attrs :font))
               (height (plist-get attrs :height)))
                (setq ok/current-font font)
                (set-face-attribute 'default nil
                                 :font font
                                  :height height)))

                ;; Set the font to the default.
                (ok/switch-font ok/current-font)

                (global-set-key (kbd "C-. s f") #'ok/switch-font)
                (global-set-key (kbd "C-. s t") #'ok/switch-theme)


                ;; Taken from Johannes init.el
                ;; https://github.com/kenranunderscore/dotfiles/blob/main/modules/programs/emacs/emacs.d/init.el#L80
                (defun ok/switch-theme (name)
                "Switch themes interactively.  Similar to `load-theme' but also disables all other enabled themes."
                (interactive
                  (list (intern
                          (completing-read
                            "Theme: "
                           (mapcar #'symbol-name
                                    (-difference (custom-available-themes)
                                        custom-enabled-themes))))))
                                        (progn
                                        (mapcar #'disable-theme
                                     custom-enabled-themes)
                                     (load-theme name t)))

                (setq modus-themes-mode-line '(accented borderless (padding . 5)))
                (setq modus-themes-italic-constructs t)
                (setq modus-themes-syntax '(yellow-comments green-strings))
                (setq modus-themes-paren-match '(bold))
                (setq modus-themes-headings '((t . (monochrome))))
                (setq modus-themes-org-blocks 'gray-background)
                (setq modus-themes-fringes nil)

                ;; Set the theme to gruvbox
                (ok/switch-theme 'modus-operandi)

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
            (add-to-list 'eglot-server-programs
                         '(go-mode . ("${pkgs.gopls}/bin/gopls"))
                         '(nix-mode . ("${pkgs.nixd}/bin/nixd")))
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

        swiper = {
          enable = true;
          command = ["swiper" "swiper-all" "swiper-isearch"];
          bind = {
            "C-s" = "swiper-isearch";
          };
        };

        vertico = {
          enable = true;
          config = ''
            ;; Prefix the current candidate with “» ”. From
            ;; https://github.com/minad/vertico/wiki#prefix-current-candidate-with-arrow
            (advice-add #'vertico--format-candidate :around
              (lambda (orig cand prefix suffix index _start)
                (setq cand (funcall orig cand prefix suffix index _start))
                (concat
                 (if (= vertico--index index)
                     (propertize "» " 'face 'vertico-current)
                   "  ")
                 cand)))

            (setq vertico-count 13   ;; Number of candidates to display
                  vertico-cycle nil)

            (vertico-mode)
          '';
        };
        marginalia = {
          enable = true;
          after = ["vertico"];
          config = ''
            (setq marginalia-max-relative-age 0)

            ;; Must be in the :init section of use-package such that the mode gets
            ;; enabled right away. Note that this forces loading the package.
            (marginalia-mode)

            ;; Enable richer annotations for M-x.
            ;; Only keybindings are shown by default, in order to reduce noise for this very common command.
            ;; * marginalia-annotate-symbol: Annotate with the documentation string
            ;; * marginalia-annotate-command-binding (default): Annotate only with the keybinding
            ;; * marginalia-annotate-command-full: Annotate with the keybinding and the documentation string
            ;; (setf (alist-get 'command marginalia-annotate-alist) #'marginalia-annotate-command-full)
          '';
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

        orderless = {
          enable = true;
          config = ''
            (setq completion-styles '(orderless flex)
                  completion-category-overrides '((eglot (styles . (orderless flex)))))
          '';
        };

        magit = {
          enable = true;
          bind = {
            "C-c g" = "magic-status";
          };
          config = ''
            (setq magit-diff-refine-hunk t)
          '';
        };
      };
    };
  };
}
