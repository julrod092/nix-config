{ config, lib, pkgs, ... }:

with lib;

{
  options.hardware.razer-nari = {
    enable = mkEnableOption "Razer Nari Ultimate headset profiles for PipeWire";
  };

  config = mkIf config.hardware.razer-nari.enable {
    # Install PipeWire/ALSA card profile files
    environment.etc = {
      # ALSA card profile mixer paths
      "alsa-card-profile/mixer/paths/razer-nari-input.conf".source = ./razer-nari-input.conf;
      "alsa-card-profile/mixer/paths/razer-nari-output-game.conf".source = ./razer-nari-output-game.conf;
      "alsa-card-profile/mixer/paths/razer-nari-output-chat.conf".source = ./razer-nari-output-chat.conf;
      
      # ALSA card profile sets
      "alsa-card-profile/mixer/profile-sets/razer-nari-usb-audio.conf".source = ./razer-nari-usb-audio.conf;
    };

    # Install udev rules for device detection
    services.udev.extraRules = ''
      # Razer Nari Ultimate headset profiles
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