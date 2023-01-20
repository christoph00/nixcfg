{
  config,
  pkgs,
  lib,
  self,
  ...
}: let
  theme-css = with config.colorscheme.colors; ''
                :root {
                  --base00: #${base00}; # ----
                  --base01: #${base01}; # ---
                  --base02: #${base02}; # --
                  --base03: #${base03}; # -
                  --base04: #${base04}; # +
                  --base05: #${base05}; # ++
                  --base06: #${base06}; # +++
                  --base07: #${base07}; # ++++
                  --base08: #${base08}; # red
                  --base09: #${base09}; # orange
                  --base0A: #${base0A}; # yellow
                  --base0B: #${base0B}; # green
                  --base0C: #${base0C}; # aqua
                  --base0D: #${base0D}; # blue
                  --base0E: #${base0E}; # purple
                  --base0F: #${base0F}; # brown
                }



    .theme-dark {
      --text-selection: var(--base02);
      --background-modifier-cover: var(--base00);
      --background-primary: var(--base00);
      --background-primary-alt: var(--base01);
      --background-secondary: var(--base02);
      --background-secondary-alt: var(--base01);
      --background-modifier-success: var(--base0B);
      --background-modifier-error: var(--base08);
      --text-normal: var(--base05);
      --text-faint: var(--base04);
      --scrollbar-bg: var(--base01);
      --scrollbar-thumb-bg: var(--base02);
      --scrollbar-active-thumb-bg: var(--base03);
      --interactive-accent: var(--base03);
    }

    /*************************
     * Font selection
    *************************/

    .workspace {
      font-family: var(--font-family-editor);
    }

    .markdown-preview-view {
      font-family: var(--font-family-preview) !important;
    }

    /*************************
     * workspace
    *************************/

    /* .workspace { */
    /*   color: var(--base06) !important; */
    /*   background-color: var(--base00) !important; */
    /* } */

    /* .workspace-tabs { */
    /*   color: var(--base06) !important; */
    /*   background-color: var(--base00) !important; */
    /* } */

    /* .workspace-tab-header { */
    /*   color: var(--base06) !important; */
    /*   background-color: var(--base00) !important; */
    /* } */

    /* .workspace-tab-header-inner { */
    /*   color: var(--base02) !important; */
    /* } */

    /* .workspace-leaf { */
    /*   color: var(--base06) !important; */
    /*   background-color: var(--base00) !important; */
    /* } */

    /*************************
     * View header
    *************************/

    /* .view-header { */
    /*   background-color: var(--base00) !important; */
    /*   color: var(--base06) !important; */
    /*   border-bottom: 1px solid var(--base01); */
    /* } */

    /* .view-header-title { */
    /*   color: var(--base06) !important; */
    /* } */

    /* .view-header-title-container:after { */
    /*   background: none !important; */
    /* } */

    /* .view-content { */
    /*   background-color: var(--base00) !important; */
    /*   color: var(--base06) !important; */
    /* } */

    /* .view-action { */
    /*   color: var(--base06) !important; */
    /* } */

    /*************************
     * Nav folder
    *************************/

    /* .nav-folder-title, .nav-file-title { */
    /*   background-color: var(--base00) !important; */
    /*   color: var(--base06) !important; */
    /* } */

    /* .nav-action-button { */
    /*   color: var(--base06) !important; */
    /* } */

    /*************************
     * Markdown headers
    *************************/

    /* .cm-header-1, .markdown-preview-view h1 { */
    /*   color: var(--base0A); */
    /* } */

    /* .cm-header-2, .markdown-preview-view h2 { */
    /*   color: var(--base0B); */
    /* } */

    /* .cm-header-3, .markdown-preview-view h3 { */
    /*   color: var(--base0C); */
    /* } */

    /* .cm-header-4, .markdown-preview-view h4 { */
    /*   color: var(--base0D); */
    /* } */

    /* .cm-header-5, .markdown-preview-view h5 { */
    /*   color: var(--base0E); */
    /* } */

    /* .cm-header-6, .markdown-preview-view h6 { */
    /*   color: var(--base0E); */
    /* } */

    /*************************
     * Markdown strong and emphasis
    *************************/

    /* .cm-em, .markdown-preview-view em { */
    /*   color: var(--base0D); */
    /* } */

    /* .cm-strong, .markdown-preview-view strong { */
    /*   color: var(--base09); */
    /* } */

    /*************************
     * Markdown links
    *************************/

    .cm-link, .markdown-preview-view a {
      color: var(--base0C) !important;
    }

    .cm-formatting-link,.cm-url {
      color: var(--base03) !important;
    }

    /*************************
     * Quotes
    *************************/

    /* .cm-quote, .markdown-preview-view blockquote { */
    /*   color: var(--base0D) !important; */
    /* } */

    /*************************
     * Code blocks
    *************************/

    .HyperMD-codeblock, .markdown-preview-view pre {
      color: var(--base07) !important;
      background-color: var(--base01) !important;
    }

    .cm-inline-code, .markdown-preview-view code {
      color: var(--base07) !important;
      background-color: var(--base01) !important;
    }

    /*************************
     * Cursor
    *************************/

    .CodeMirror-cursors {
      color: var(--base0B);
      z-index: 5 !important /* fixes a bug where cursor is hidden in code blocks */
    }



  '';
in {
  home.packages = with pkgs; [
    obsidian
  ];
  home.persistence = {
    "/nix/persist/home/christoph".directories = [".config/obsidian"];
  };

  home.file."Dokumente/.obsidian/snippets/base16-theme.css".text = theme-css;
}
