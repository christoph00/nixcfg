{
  config,
  self,
  ...
}: {
  age.secrets.user-password.file = "${self}/secrets/christoph-password.age";
}
