{
  config,
  lib,
  pkgs,
  ...
}: let
  emacsPackage = pkgs.emacs;
  goPackage =
    if pkgs ? unstable && pkgs.unstable ? go
    then pkgs.unstable.go
    else pkgs.go;
  opencodePackage =
    if pkgs ? unstable && pkgs.unstable ? opencode
    then pkgs.unstable.opencode
    else pkgs.opencode;
  vtermModuleCmakeArgs =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "-DUSE_SYSTEM_LIBVTERM=Off"
    else "-DCMAKE_PREFIX_PATH=${pkgs.libvterm}";
  glibtool = pkgs.writeShellScriptBin "glibtool" ''
    exec ${pkgs.libtool}/bin/libtool "$@"
  '';

  emacsEditor = pkgs.writeShellScriptBin "emacs-editor" ''
    set -e

    if ! ${emacsPackage}/bin/emacsclient --eval '(emacs-pid)' >/dev/null 2>&1; then
      ${emacsPackage}/bin/emacs --daemon
    fi

    exec ${emacsPackage}/bin/emacsclient -t "$@"
  '';

  metalsEmacs = pkgs.writeShellScriptBin "metals-emacs" ''
    exec ${lib.getExe pkgs.metals} "$@"
  '';

  alejandraStdin = pkgs.writeShellScriptBin "alejandra-stdin" ''
    exec ${lib.getExe pkgs.alejandra} -q - "$@"
  '';
  agentShellSource = builtins.fetchGit {
    url = "https://github.com/kdoomsday/agent-shell.git";
    rev = "20faf1cd827bd48375bd7d6f6001257937d6e026";
  };

  nixTools = with pkgs; [
    alejandra
    deadnix
    nil
    nixd
    nixfmt
    nixpkgs-fmt
    statix
    treefmt
  ];

  scalaTools = with pkgs; [
    scalafmt
  ];

  javaTools = with pkgs; [
    google-java-format
  ];

  shellTools = with pkgs; [
    bash-language-server
    shellcheck
    shfmt
  ];

  dataTools = with pkgs; [
    marksman
    markdownlint-cli
    taplo
    vscode-langservers-extracted
    yaml-language-server
    yamlfmt
    yamllint
  ];

  vtermTools = with pkgs;
    [
      cmake
      git
      gnumake
      libtool
      pkg-config
      zsh
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [glibtool]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [pkgs.libvterm];
  # Create a single directory with all vterm tools to reduce PATH length
  vtermToolsWrapper = pkgs.symlinkJoin {
    name = "vterm-tools-wrapper";
    paths = vtermTools;
    postBuild = ''
      # Create a bin directory with symlinks to all tools
      mkdir -p $out/bin
      for pkg in ${lib.concatMapStringsSep " " (p: p.name) vtermTools}; do
        if [ -d "$out/$pkg/bin" ]; then
          for bin in "$out/$pkg/bin"/*; do
            ln -sf "$bin" "$out/bin/$(basename "$bin")" 2>/dev/null || true
          done
        fi
      done
    '';
  };
  vtermToolPath = "${vtermToolsWrapper}/bin";

  goTools = with pkgs; [
    goPackage
    delve
    godef
    gofumpt
    goimports-reviser
    golangci-lint
    golines
    gomodifytags
    go-outline
    gopkgs
    gopls
    gotests
    gotools
    impl
    reftools
  ];

  haskellTools = with pkgs; [
    cabal-install
    ghc
    haskell-language-server
    hlint
    fourmolu
    ormolu
    stack
    stylish-haskell
    haskellPackages.cabal-fmt
    haskellPackages.hasktags
    haskellPackages.hoogle
  ];
in {
  programs.emacs = {
    enable = true;
    package = emacsPackage;
  };

  home.packages =
    [
      emacsEditor
      metalsEmacs
      pkgs.metals
    ]
    ++ nixTools
    ++ scalaTools
    ++ javaTools
    ++ shellTools
    ++ dataTools
    ++ vtermTools
    ++ goTools
    ++ haskellTools;

  home.sessionPath = [
    vtermToolPath
    "$HOME/.cabal/bin"
    "$HOME/.local/bin"
    "$HOME/go/bin"
  ];

  home.sessionVariables = {
    SPACEMACS_SHELL = lib.getExe pkgs.zsh;
    VTERM_MODULE_CMAKE_ARGS = vtermModuleCmakeArgs;
  };

  home.activation.bootstrapSpacemacs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    spacemacs_dir="$HOME/.emacs.d"

    if [ ! -e "$spacemacs_dir" ]; then
      echo "Bootstrapping Spacemacs into $spacemacs_dir"
      ${pkgs.git}/bin/git clone --depth 1 --branch develop https://github.com/syl20bnr/spacemacs "$spacemacs_dir"
    elif [ ! -d "$spacemacs_dir/.git" ]; then
      echo "Skipping Spacemacs bootstrap: $spacemacs_dir exists and is not a git checkout." >&2
    fi
  '';

  home.file = {
    ".spacemacs".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix-config/modules/home-manager/programs/emacs/.spacemacs";
    ".emacs.d/private/agent-shell".source = agentShellSource;
  };
}
