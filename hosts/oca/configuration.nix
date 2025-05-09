{ inputs, ... }:
{
  imports = [ inputs.self.nixosModules.host ];

  nixpkgs.hostPlatform = "aarch64-linux";
}
