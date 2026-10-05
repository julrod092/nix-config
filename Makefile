.PHONY: help format format-check flake-update flake-check build-linux lint secret-check test emacs-check

help:
	@printf '%s\n' \
		"Available targets:" \
		"  format         - Format Nix sources" \
		"  format-check   - Check Nix source formatting" \
		"  flake-update   - Update workstation flake inputs" \
		"  flake-check    - Evaluate workstation flake checks" \
		"  build-linux    - Build Linux workstation checks" \
		"  lint           - Check shell scripts" \
		"  emacs-check    - Check Emacs package ownership and migration" \
		"  secret-check   - Enforce encrypted payload boundaries" \

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

emacs-check:
	@emacs -Q --batch -l modules/home-manager/programming/editors/emacs/tests/package-policy-tests.el -f ert-run-tests-batch-and-exit
	@PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests -p 'test_emacs_package_migration.py' -v
	@PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests -p 'test_emacs_bootstrap.py' -v

lint:
	@shellcheck scripts/check-secret-hygiene  modules/home-manager/scripts/bin/*

secret-check:
	@./scripts/check-secret-hygiene
	@gitleaks dir --redact --no-banner --verbose .
	@gitleaks git --redact --no-banner --verbose .
