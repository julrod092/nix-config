{ config, pkgs, lib, ... }:

{
  # Enable NVIDIA drivers
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        cudaPackages.cuda_nvcc
        cudaPackages.cuda_cudart
        nvidia-vaapi-driver
        vaapiVdpau
        libvdpau-va-gl
      ];
    };

    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting.enable = true;
      powerManagement.enable = false;
      nvidiaSettings = true;
      open = true;
    };
  };

  # Install CUDA tools
  environment.systemPackages = with pkgs; [
    cudaPackages.cuda_nvcc
    cudaPackages.cuda_cudart
  ];

  # Set necessary environment variables
  environment.sessionVariables = lib.mkForce {
    CUDA_PATH = "${pkgs.cudaPackages.cuda_cudart}";
    LD_LIBRARY_PATH = "${pkgs.cudaPackages.cuda_cudart}/lib:${pkgs.cudaPackages.cuda_nvcc}/lib:/run/opengl-driver/lib";
    # Add variables to help with EGL/OpenGL issues
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
  };
}
