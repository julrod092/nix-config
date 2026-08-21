{
  inputs,
  nixosModules,
  ...
}: {
  imports = [
    inputs.arctis-sound-manager.nixosModules.default
    "${nixosModules}/common"
  ];
}
