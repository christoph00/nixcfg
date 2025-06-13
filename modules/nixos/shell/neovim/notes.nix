{
  flake,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.programs.nvf.enable {

    programs.nvf.settings = {
      vim.notes = {
        obsidian = {
          enable = true;
          setupOpts = {
            mappings = [ ];
            log_level = lib.generators.mkLuaInline "vim.log.levels.ERROR";

            workspaces = [
              {
                name = "personal";
                path = "~/Notes";
              }
            ];
            notes_subdir = "Notes";
            attachments.img_folder = "Assets";
            daily_notes = {
              folder = "Daily";
              date_format = "%Y-%m-%d";
              default_tags = [ "daily-notes" ];
            };

            picker = {
              name = "fzf-lua";
              mappings.new = "<C-x>";
              mappings.insert_link = "<C-l>";
              tag_mappings.tag_note = "<C-x>";
              tag_mappings.insert_tag = "<C-l>";
            };

            # [[this]] type of links
            preferred_link_style = "wiki";
          };
        };
      };
    };
  };
}
