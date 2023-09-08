{
  config,
  self,
  ...
}: {
  age.secrets.user-password.file = "${self}/secrets/christoph-password.age";
  config.age.secrets.tailscaleAuthKey.file = "${self}/secrets/tailscale-preauthkey";
}
