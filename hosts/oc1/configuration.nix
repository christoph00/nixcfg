{ inputs, ... }:
{
  imports = [ inputs.self.nixosModules.host ];
  nixpkgs.hostPlatform = "x86_64-linux";

  networking.hostName = "oc1";

  host.bootstrap = true;
}
