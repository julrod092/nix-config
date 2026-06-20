{pkgs, ...}: {
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    host = "0.0.0.0";
    openFirewall = true;
    environmentVariables = {
      OLLAMA_KEEP_ALIVE = "30m";
      OLLAMA_LOAD_TIMEOUT = "10m";
    };
    loadModels = ["gpt-oss:20b"];
  };
}
