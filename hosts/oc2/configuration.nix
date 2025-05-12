{ inputs, ... }:
{
  imports = [ inputs.self.nixosModules.host ];
  nixpkgs.hostPlatform = "x86_64-linux";

  networking.hostName = "oc2";

  sys.state.enable = false;
  sys.disk.type = "xfs";
}
