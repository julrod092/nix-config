{ config, lib, pkgs, ... }:

with lib;

let
  razer-nari-profiles = pkgs.fetchFromGitHub {
    owner = "imustafin";
    repo = "razer-nari-pulseaudio-profile";
    rev = "6b632edfb0b51fc7a3227b8f5b6c3a8c4616661e"; # Latest commit
    sha256 = "sha256-ZxdTRxBIodewAqflYFfpB5fYlyWqStvBxSovyA+LIEk=";
  };
in
{
  options.hardware.razer-nari = {
    enable = mkEnableOption "Razer Nari Ultimate headset profiles for PipeWire";
  };

  config = mkIf config.hardware.razer-nari.enable {
    # Install PipeWire/ALSA card profile files from the fetched repository
    environment.etc = {
      # ALSA card profile mixer paths (PipeWire compatible paths)
      "alsa-card-profile/mixer/paths/razer-nari-input.conf".source = 
        "${razer-nari-profiles}/razer-nari-input.conf";
      "alsa-card-profile/mixer/paths/razer-nari-output-game.conf".source = 
        "${razer-nari-profiles}/razer-nari-output-game.conf";
      "alsa-card-profile/mixer/paths/razer-nari-output-chat.conf".source = 
        "${razer-nari-profiles}/razer-nari-output-chat.conf";
      
      # ALSA card profile sets
      "alsa-card-profile/mixer/profile-sets/razer-nari-usb-audio.conf".source = 
        "${razer-nari-profiles}/razer-nari-usb-audio.conf";
    };

    # Install udev rules for device detection (using PipeWire-compatible rules)
    services.udev.extraRules = ''
      # Razer Nari Ultimate headset profiles (PipeWire/ACP compatible)
      # This will automatically apply the custom profile when the headset is connected
      ATTRS{idVendor}=="1532", ATTRS{idProduct}=="051a", ENV{ACP_PROFILE_SET}="razer-nari-usb-audio.conf"
      ATTRS{idVendor}=="1532", ATTRS{idProduct}=="051c", ENV{ACP_PROFILE_SET}="razer-nari-usb-audio.conf"  
      ATTRS{idVendor}=="1532", ATTRS{idProduct}=="051d", ENV{ACP_PROFILE_SET}="razer-nari-usb-audio.conf"
    '';

    # Ensure PipeWire is enabled (this module requires it)
    assertions = [
      {
        assertion = config.services.pipewire.enable;
        message = "Razer Nari profiles require PipeWire to be enabled. Set services.pipewire.enable = true;";
      }
    ];
  };
} 