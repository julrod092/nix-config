# 
{pkgs, lib, inputs, outputs, ...}: 
{

  imports = [
    inputs.zen-browser.homeModules.twilight
  ];

  programs = lib.mkIf (!pkgs.stdenv.isDarwin) {
    zen-browser = {
      enable = true;
      policies = {
        AutofillAddressEnabled = true;
        AutofillCreditCardEnabled = false;
        DisableAppUpdate = true;
        DisableFeedbackCommands = true;
        DisableFirefoxStudies = true;
        DisablePocket = true; # save webs for later reading
        DisableTelemetry = true;
        DontCheckDefaultBrowser = true;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        ExtensionSettings =
          with builtins;
          let
            extension = shortId: uuid: {
              name = uuid;
              value = {
                install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
                installation_mode = "normal_installed";
              };
            };
          in
          listToAttrs [
            (extension "ublock-origin" "uBlock0@raymondhill.net")
            (extension "proton-pass" "78272b6fa58f4a1abaac99321d503a20@proton.me")
            (extension "privacy-badger17" "jid1-MnnxcxisBPnSXQ@jetpack")
            (extension "twitch_5" "twitch5@coolcmd")
          ];
        # find more options here: https://mozilla.github.io/policy-templates/`
      };
    };
  }; 
}
