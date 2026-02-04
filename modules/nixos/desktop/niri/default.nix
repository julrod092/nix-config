{ config, pkgs, ... }:

{ 
  
  services.displayManager.ly.enable = true; 
  programs.niri.enable = true;
}
