.PHONY: help format format-check flake-update flake-check build-linux lint secret-check test

help:
	@printf '%s\n' \
		"Available targets:" \
		"  format         - Format Nix sources" \
		"  format-check   - Check Nix source formatting" \
		"  flake-update   - Update workstation flake inputs" \
		"  flake-check    - Evaluate workstation flake checks" \
		"  build-linux    - Build Linux workstation checks" \
		"  lint           - Check shell scripts" \
		"  secret-check   - Enforce encrypted payload boundaries" \
		"  test           - Run synthetic safety tests"

format:
	@alejandra .

format-check:
	@alejandra --check .

flake-update:
	@nix flake update

flake-check:
	@nix flake check --no-build --all-systems path:.

build-linux:
	@nix build path:.#checks.x86_64-linux.nix-desktop path:.#checks.x86_64-linux.home-julrod --no-link

lint:
	@shellcheck scripts/check-secret-hygiene scripts/validate-tailscale-preferences scripts/render-tailscale-flags scripts/apply-tailscale-preferences modules/home-manager/scripts/bin/* tests/secret-hygiene.sh tests/tailscale-preferences.sh

secret-check:
	@./scripts/check-secret-hygiene
	@gitleaks dir --redact --no-banner .
	@gitleaks git --redact --no-banner .

test:
	@bash tests/secret-hygiene.sh
	@bash tests/tailscale-preferences.sh
