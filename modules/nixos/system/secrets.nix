{
  config,
  self,
  ...
}: {
  age.secrets.user-password.file = "${self}/secrets/christoph-password.age";
  age.secrets.tailscaleAuthKey.file = "${self}/secrets/tailscale-preauthkey";
  age.secrets.netbirdenv.file = "${self}/secrets/netbird.env";
}
