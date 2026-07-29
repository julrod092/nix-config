{
  agentShellSource,
  config,
  lib,
  pkgs,
  ...
}: let
  emacsPackage =
    if pkgs.stdenv.hostPlatform.isLinux
    then pkgs.emacs-pgtk
    else pkgs.emacs;

  goPackage =
    if pkgs ? unstable && pkgs.unstable ? go
    then pkgs.unstable.go
    else pkgs.go;

  alejandraStdin = pkgs.writeShellScriptBin "alejandra-stdin" ''
    exec ${lib.getExe pkgs.alejandra} --quiet - "$@"
  '';

  nixTools = with pkgs; [
    alejandra
    deadnix
    nil
    nixd
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
    extraPackages = epkgs: [
      epkgs.lsp-mode
    ];
  };

  home.packages =
    [
      alejandraStdin
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
    "$HOME/.cabal/bin"
    "$HOME/.local/bin"
    "$HOME/go/bin"
  ];

  home.sessionVariables = {
    SPACEMACS_SHELL = lib.getExe pkgs.zsh;
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
