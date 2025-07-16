# Razer Nari Ultimate Headset Support

This module provides PipeWire/ALSA profiles for the Razer Nari Ultimate gaming headset, enabling proper dual-channel audio support (game and chat channels).

## Overview

The Razer Nari Ultimate headset has two stereo audio outputs:
- **Game Output**: For game audio, music, and general sound
- **Chat Output**: For voice chat and communication

This unusual design allows separate volume controls for voice and game audio, which is useful for gaming. By default, PipeWire only recognizes the chat output (mono). This module enables both outputs with proper stereo support.

## Supported Devices

- Razer Nari Ultimate (USB Product IDs: 051a, 051c, 051d)
- Razer Nari (other variants may work)

## Installation

Add the module to your NixOS configuration:

```nix
{
  imports = [
    # ... other imports
    "${nixosModules}/hardware/razer-nari"
  ];

  # Enable the module
  hardware.razer-nari.enable = true;
}
```

**Note**: This module requires PipeWire to be enabled. The module will assert this requirement and provide an error message if PipeWire is not configured.

## What This Module Does

1. **Installs ALSA card profiles** to `/etc/alsa-card-profile/mixer/`:
   - Mixer paths for input, game output, and chat output
   - Profile sets that define the dual-channel configuration

2. **Adds udev rules** that automatically apply the custom profile when the headset is connected

3. **Provides proper channel mapping**:
   - Chat channel: Mono input/output for voice
   - Game channel: Stereo output for games and music

## Usage

After installation and rebooting (or reconnecting your headset):

1. **Connect your Razer Nari Ultimate headset**
2. **Open audio settings** (pavucontrol or system settings)
3. **Select the appropriate profile**:
   - You should see options like "Game Output + Chat Output + Chat Input"
   - Choose the profile that includes both game and chat outputs

## Troubleshooting

### Headset not detected
- Ensure the headset is properly connected via USB
- Check if the device is recognized: `lsusb | grep 1532`
- Reload udev rules: `sudo udevadm control --reload-rules && sudo udevadm trigger`

### Profile not available
- Restart PipeWire: `systemctl --user restart pipewire`
- Check if files are installed:
  ```bash
  ls /etc/alsa-card-profile/mixer/paths/razer-nari*
  ls /etc/alsa-card-profile/mixer/profile-sets/razer-nari*
  ```

### Only getting mono audio
- Make sure you've selected the correct profile in pavucontrol
- Look for "Game Output" in the output devices list
- The "Chat Output" is mono by design (for voice)

## Configuration Files

This module includes the following configuration files from the [razer-nari-pulseaudio-profile](https://github.com/imustafin/razer-nari-pulseaudio-profile) project:

- `razer-nari-input.conf` - Microphone input configuration
- `razer-nari-output-game.conf` - Game audio output (stereo)
- `razer-nari-output-chat.conf` - Chat audio output (mono)
- `razer-nari-usb-audio.conf` - Main profile configuration

## Credits

This module is based on the work from:
- [imustafin/razer-nari-pulseaudio-profile](https://github.com/imustafin/razer-nari-pulseaudio-profile)
- Originally forked from [DemonTPx/steelseries-arctis-5-pulseaudio-profile](https://github.com/DemonTPx/steelseries-arctis-5-pulseaudio-profile) 