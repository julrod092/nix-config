{pkgs, ...}: {
  # Ensure normcap package installed
  home.packages = with pkgs; [
    vmware-horizon-client
  ];
}
