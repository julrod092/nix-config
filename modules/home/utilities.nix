{...}: {
  config.dendritic.homeModules.utilities = {
    lib,
    pkgs,
    ...
  }: {
    programs.bat.enable = true;
    catppuccin.bat.enable = true;

    programs.btop = {
      enable = true;
      settings.vim_keys = true;
    };
    catppuccin.btop.enable = true;

    programs.fastfetch = {
      enable = true;
      settings = {
        logo.type = "none";
        display.separator = "->   ";
        modules = [
          { type = "title"; format = "{6}{7}{8}"; }
          "break"
          { type = "custom"; format = "┌───────────────────────────── System Information ─────────────────────────────┐"; }
          "break"
          { key = "     OS           "; keyColor = "red"; type = "os"; }
          { key = "    󰌢 Machine      "; keyColor = "green"; type = "host"; }
          { key = "     Kernel       "; keyColor = "magenta"; type = "kernel"; }
          { key = "    󰏖 Packages     "; type = "packages"; }
          { key = "    󰅐 Uptime       "; keyColor = "red"; type = "uptime"; }
          { key = "    󰍹 Resolution   "; keyColor = "yellow"; type = "display"; compactType = "original-with-refresh-rate"; }
          { key = "     WM           "; keyColor = "blue"; type = "wm"; }
          { key = "     DE           "; keyColor = "green"; type = "de"; }
          { key = "     Shell        "; keyColor = "cyan"; type = "shell"; }
          { key = "     Terminal     "; keyColor = "red"; type = "terminal"; }
          { key = "    󰻠 CPU          "; keyColor = "yellow"; type = "cpu"; }
          { key = "    󰍛 GPU          "; keyColor = "blue"; type = "gpu"; }
          { key = "    󰑭 Memory       "; keyColor = "magenta"; type = "memory"; }
          { key = "    󰩟 Local IP     "; keyColor = "red"; type = "localip"; }
          { key = "    󰩠 Public IP    "; keyColor = "cyan"; type = "publicip"; }
          "break"
          { type = "custom"; format = "└──────────────────────────────────────────────────────────────────────────────┘"; }
          "break"
          { paddingLeft = 34; symbol = "circle"; type = "colors"; }
        ];
      };
    };

    home.packages = lib.optionals (!pkgs.stdenv.hostPlatform.isDarwin) [ pkgs.albert ];

    xdg.configFile = lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) {
      "albert/config".text = ''
        [General]
        showTray=false
        telemetry=false

        [applications]
        enabled=true
        global_handler_enabled=true

        [chromium]
        enabled=true
        fuzzy=false
        global_handler_enabled=false
        trigger=bm

        [system]
        command_lock=loginctl lock-session
        command_logout=$HOME/.local/bin/quit-all-applications
        command_poweroff=systemctl poweroff -i
        command_reboot=systemctl reboot -i
        enabled=true
        logout_enabled=true
        title_logout=Quit All Applications
        title_poweroff=Shutdown
        trigger=sys

        [widgetsboxmodel]
        alwaysOnTop=true
        clearOnHide=true
        displayScrollbar=false
        followCursor=false
        hideOnFocusLoss=true
        historySearch=true
        itemCount=10
        showCentered=true
      '';
    };

    systemd.user.services.albert = lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) {
      Unit = {
        Description = "Albert Launcher";
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.albert}/bin/albert";
        Restart = "always";
        RestartSec = "0s";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
