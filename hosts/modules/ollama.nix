{...}: {
  # Gen AI models runner

  # Open web ui
  environment.systemPackages = with pkgs; [
    open-webui
  ];

  services.ollama = {
    enable = true;
    # Enable AMD GPU acceleration
    acceleration = "cuda";
  };
}
