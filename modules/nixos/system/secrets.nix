{
  config,
  self,
  ...
}: {
  age.secrets.christoph-password.file = "${self}/secrets/christoph-password.age";
}
