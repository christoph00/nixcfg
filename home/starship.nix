{
  programs.starship = {
    enable = true;
    settings = {
      username = {
        format = "[$user](bold blue) ";
        disabled = false;
        show_always = true;
      };
      hostname = {
        ssh_only = false;
        format = "on [$hostname](bold red) ";
        trim_at = ".local"; # TODO: set to netwok domain
        disabled = false;
      };
    };
  };
}
