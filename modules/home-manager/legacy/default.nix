{
  self,
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.agenix.homeManagerModules.age
    ./legacy
  ];
}
