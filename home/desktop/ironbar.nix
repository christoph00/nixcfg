{inputs, ...}: {
  programs.ironbar = {
    enable = true;
    package = inputs.ironbar.packages.x86_64-linux.default;
  };
}
