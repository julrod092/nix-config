# Variables (override these as needed)
HOSTNAME ?= $(shell hostname)
FLAKE ?= .#$(HOSTNAME)
EXPERIMENTAL ?= --extra-experimental-features "nix-command flakes"

.PHONY: help install-nix install-nix-darwin darwin-rebuild nixos-rebuild \
	nix-gc flake-update flake-check bootstrap-mac \
	colmena-eval colmena-local colmena-prime-build colmena-prime-test colmena-prime-boot \
	colmena-prime-switch colmena-prime-keys

help:
	@echo "Available targets:"
	@echo "  install-nix          - Install the Nix package manager"
	@echo "  install-nix-darwin   - Install nix-darwin using flake $(FLAKE)"
	@echo "  darwin-rebuild       - Rebuild the nix-darwin configuration"
	@echo "  nixos-rebuild        - Rebuild the NixOS configuration"
	@echo "  nix-gc               - Run Nix garbage collection"
	@echo "  flake-update         - Update flake inputs"
	@echo "  flake-check          - Check the flake for issues"
	@echo "  colmena-eval         - Evaluate the NixOS hive"
	@echo "  colmena-local        - Apply nix-desktop locally with Colmena"
	@echo "  colmena-prime-build  - Build prime-mini in its remote Nix store"
	@echo "  colmena-prime-test   - Test-activate prime-mini"
	@echo "  colmena-prime-boot   - Install prime-mini for the next boot"
	@echo "  colmena-prime-switch - Switch prime-mini immediately"
	@echo "  colmena-prime-keys   - Upload prime-mini secrets only"
	@echo "  bootstrap-mac        - Install Nix and nix-darwin sequentially"

install-nix:
	@echo "Installing Nix..."
	@sudo curl -L https://nixos.org/nix/install | sh -s -- --daemon --yes
	@echo "Nix installation complete."

install-nix-darwin:
	@echo "Installing nix-darwin..."
	@nix run nix-darwin $(EXPERIMENTAL) -- switch --flake $(FLAKE)
	@echo "nix-darwin installation complete."

darwin-rebuild:
	@echo "Rebuilding darwin configuration..."
	@darwin-rebuild switch --flake $(FLAKE)
	@echo "Darwin rebuild complete."

nixos-rebuild:
	@echo "Rebuilding NixOS configuration..."
	@sudo nixos-rebuild switch --flake $(FLAKE)
	@echo "NixOS rebuild complete."

nix-gc:
	@echo "Collecting Nix garbage..."
	@nix-collect-garbage -d
	@echo "Garbage collection complete."

flake-update:
	@echo "Updating flake inputs..."
	@nix flake update
	@echo "Flake update complete."

flake-check:
	@echo "Checking flake..."
	@nix flake check --no-build --all-systems
	@echo "Flake check complete."

colmena-eval:
	@nix run .#colmena -- eval -E '{ nodes, ... }: builtins.attrNames nodes'

colmena-local:
	@nix run .#colmena -- apply-local --sudo

colmena-prime-build:
	@./scripts/deploy-prime-mini build

colmena-prime-test:
	@./scripts/deploy-prime-mini test

colmena-prime-boot:
	@./scripts/deploy-prime-mini boot

colmena-prime-switch:
	@./scripts/deploy-prime-mini switch

colmena-prime-keys:
	@nix run .#colmena -- upload-keys --on prime-mini

bootstrap-mac: install-nix install-nix-darwin
