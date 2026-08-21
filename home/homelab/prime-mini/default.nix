{nhModules, ...}: {
  imports = [
    "${nhModules}/roles/homelab"
    "${nhModules}/services/stacks/default.nix"
  ];

  nh.primeMiniStack.enable = true;
}
