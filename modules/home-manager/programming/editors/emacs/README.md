# Emacs package ownership

Nix owns `envrc`, `lsp-mode`, `vterm`, and their complete propagated Lisp
dependency set. Spacemacs owns the remaining Lisp packages and configures the
existing shell/LSP layers. External language-server executables are supplied by
Nix or an explicitly activated project environment.

The Nix build inspects the wrapped Emacs package descriptors and generates
`~/.emacs.d/nix-packages.el` and `nix-packages.json`. No dependency-name list is
maintained by hand, and no build output is imported during Nix evaluation.
Spacemacs marks these packages `:location site` and freezes them. They are pinned
to the deliberately unavailable `nix-managed` archive so an incompatible newer
dependency fails visibly instead of installing a second ELPA copy. Update the
flake's package set to satisfy such a requirement; do not add an archive URL with
that name.

VTerm's Lisp and native module must resolve to the same Nix package. Start Emacs
using the Nix-wrapped CLI or GUI application. Do not copy modules between package
versions or enable automatic VTerm compilation.

## One-time migration

Activate the new generated configuration, then fully quit Emacs before moving
packages. The migration command defaults to a dry-run:

```sh
python3 scripts/migrate-emacs-nix-packages
python3 scripts/migrate-emacs-nix-packages --apply
```

Only matching package directories under the user ELPA tree are moved. Unrelated
packages and Spacemacs rollback history are retained. A timestamped quarantine
and `migration.json` record are stored under
`~/.emacs.d/.cache/nix-package-quarantine/`. Symlinked package directories require
manual inspection; the tool refuses to overwrite packages during restoration.

To reverse a migration when reverting the ownership configuration:

```sh
python3 scripts/migrate-emacs-nix-packages --restore /path/to/migration.json
```

Do not restore Nix-owned packages through a Spacemacs rollback while retaining
this ownership policy. Restart after migration: already loaded Lisp/modules
cannot be treated as migrated in place. Regenerate a package-quickstart cache if
you explicitly enabled one; the default configuration does not enable it.

## Startup and updates

Fresh bootstrap checks out the tested revision pinned in `default.nix`, before
Home Manager links generated files. It publishes a completed temporary checkout
so interrupted fetches can be retried. Existing checkouts are preserved. To change
the Spacemacs revision, update the pin and deliberately update the existing Git
checkout to the tested commit; activation never resets it automatically.

`.spacemacs` remains an out-of-store link for live editing. A Nix-generation
rollback alone therefore does not roll back that file; use Git to restore it.
Package/session/cache state remains writable. The broad `.spacemacs.env` snapshot
is no longer loaded or generated; GUI PATH/MANPATH are imported once through a
non-interactive login shell, before enabling buffer-local envrc environments.
Nix sets the global shell/JDK baseline; project environments may override it.
Go lint availability and LSP diagnostic routing are rechecked after envrc reloads;
removing a project linter restores the previous diagnostic provider.

Run `make emacs-check` and `make flake-check` before deploying changes. Until new
files are tracked by Git, build with a `path:` flake URL, as the Makefile does.
Then verify GUI VTerm creation and language-server initialization on the native
macOS and NixOS machines.
