{ config, pkgs, lib, ... }:

{
  # Enable NVIDIA drivers
  services.xserver.videoDrivers = [ "nvidia" ];

  # Configure Graphics
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      stable.cudaPackages.cuda_nvcc
      stable.cudaPackages.cuda_cudart
    ];
  };

  # Configure NVIDIA settings
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    powerManagement.enable = false;
    nvidiaSettings = true;
    open = true;
  };

  # Install CUDA tools
  environment.systemPackages = with pkgs; [
    stable.cudaPackages.cuda_nvcc
    stable.cudaPackages.cuda_cudart
  ];

  # Set necessary environment variables
  environment.sessionVariables = lib.mkForce {
    CUDA_PATH = "${pkgs.stable.cudaPackages.cuda_cudart}";
    LD_LIBRARY_PATH = "${pkgs.stable.cudaPackages.cuda_cudart}/lib:${pkgs.stable.cudaPackages.cuda_nvcc}/lib:/run/opengl-driver/lib";
  };
}
