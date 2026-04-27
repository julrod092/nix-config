{...}: {
  config.dendritic.homeModules.rust = {
    lib,
    pkgs,
    ...
  }: {
    home.packages = [ pkgs.rustup ];
    home.sessionPath = [ "$HOME/.cargo/bin" ];

    home.activation.initRustup = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p "$HOME/.cargo/bin"

      if ! ${pkgs.rustup}/bin/rustup toolchain list | grep -q '^stable'; then
        ${pkgs.rustup}/bin/rustup toolchain install stable --profile default --no-self-update
      fi

      if ! ${pkgs.rustup}/bin/rustup show active-toolchain > /dev/null 2>&1; then
        ${pkgs.rustup}/bin/rustup default stable
      fi

      COMPONENT_CHECK_FILE="$HOME/.config/rustup_components_checked"
      if [ ! -f "$COMPONENT_CHECK_FILE" ] || [ "$(find "$COMPONENT_CHECK_FILE" -mmin +1440 2>/dev/null)" ]; then
        ${pkgs.rustup}/bin/rustup component add rustfmt clippy rust-analyzer || true
        touch "$COMPONENT_CHECK_FILE"
      fi
    '';
  };
}
