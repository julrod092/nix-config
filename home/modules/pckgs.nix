{pkgs, ...}: {
  
  home.packages = with pkgs; [
    zed-editor
    vmware-horizon-client
    spicetify-cli
  ];
}
