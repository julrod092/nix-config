{pkgs, ...}: {
  # Ensure normcap package installed
  home.packages = with pkgs; [
    mware-horizon-client
  ];
}
