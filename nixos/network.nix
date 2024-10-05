{ config, lib, pkgs, ... }: {

  # Enable networking
  networking = {
    hostName = "julrod-nix-desktop";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedUDPPorts = [ 24800 ];
      allowedTCPPorts = [ 24800 ];
      extraCommands = ''
        iptables -A INPUT -s 192.168.68.55/22 -j ACCEPT
      '';
      # extraStopCommands = '' 
      #   iptables -D INPUT -s 192.168.68.55/22 -j ACCEPT
      # '';
    };
  };

  # services.nginx = {
  #   enable = true;
  #   recommendedProxySettings = true;
  #   virtualHosts."julrod.dev" = {
  #     enableACME = false;
  #     forceSSL = false;
  #     locations = {
  #       "/redpanda" = {
  #         proxyPass = "http://localhost:8080";
  #       };
  #     };
  #   };
  # };
    # nftables = {
    #   enable = true;
    #   ruleset = ''
    #     table ip filter {
    #       # Define the input chain that will group rules inside the table
    #       chain input {
    #           type filter hook input priority filter; policy drop;
              
    #           # Allow all traffic on the loopback interface
    #           iif lo accept
              
    #           # Accept established and related connections
    #           ct state established,related accept
              
    #           # Allow SSH traffic
    #           tcp dport 22 accept
              
    #           # Drop all other incoming traffic
    #       }
          
    #       # Define the output chain
    #       chain output {
    #           type filter hook output priority 0; policy accept;
    #       }
          
    #       # Define the forward chain
    #       chain forward {
    #           type filter hook forward priority 0; policy drop;
    #       }
    #     }
    #   '';
    # };
}
