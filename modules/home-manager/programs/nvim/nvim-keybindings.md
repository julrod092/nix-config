# Neovim Keybindings

This reference covers the keybindings configured in
`/Users/julian/.nix-config/modules/home-manager/programs/nvim/default.nix`
(a Nixvim-based configuration shaped to feel like LazyVim). The leader key
(`<leader>`) is **Space**. Press `<leader>` and wait to let **which-key** show
the available follow-up keys interactively.

Keys marked _(plugin default)_ come from the enabled plugin's own default
mappings rather than an explicit binding in the module.

## How to read these keys

This reference uses Vim's standard `:help`-style notation. Anything inside
`< >` is a named key or a modifier combo; anything without is literal keys
pressed one after another. Two rules cover most cases:

- **No angle brackets = press the keys in sequence** (Normal mode): `gd` = `g`
  then `d`; `ciw` = `c`, `i`, `w`.
- **A capital letter means Shift**: `K` = Shift+k, so `<S-l>` and `L` are the
  same key.

| Notation | Means | You press |
|---|---|---|
| `<leader>` | The leader prefix (configured to **Space**) | Spacebar |
| `<localleader>` | Filetype-local leader (also Space) | Spacebar |
| `<CR>` | Carriage Return | Enter / Return |
| `<Esc>` | Escape | Esc |
| `<Tab>` / `<S-Tab>` | Tab / Shift+Tab | Tab / Shift+Tab |
| `<BS>` | Backspace | Backspace |
| `<C-x>` | Ctrl + key (e.g. `<C-h>`) | Ctrl held + x |
| `<S-x>` | Shift + key (e.g. `<S-l>`) | Shift held + x |
| `<A-x>` / `<M-x>` | Alt / Meta + key | Alt held + x |
| `<C-Up>` / `<C-Down>` | Ctrl + arrow key | Ctrl + ↑ / ↓ |
| `<F5>` … | Function keys | F5 … |
| `<cmd>…<cr>` | Runs an Ex command for you | (just triggers `:…`) |

Examples: `<leader>ff` = Space then `f` `f` (find files) · `<C-h>` = Ctrl+h
(left window) · `<S-l>` = Shift+l (next buffer) · `[d` = `[` then `d` (previous
diagnostic).

Other docs sometimes spell these `SPC`, `CTRL-h`, `SHIFT-l` — same keys, just a
different style.

**Tip:** press **Space** in Neovim and pause — **which-key** shows every next
key and what it does.

## Core

| Name | Keys | Description |
|---|---|---|
| Leader | `<leader>` | Opens the which-key popup for leader bindings. |
| Local leader | `<localleader>` | Local leader, used by some filetype plugins. |
| Command mode | `:` | Runs an Ex command. |
| Save file | `<leader>w` | Writes the current buffer. |
| Quit window | `<leader>q` | Closes the current window. |
| Format buffer | `<leader>cf` | Formats the buffer with conform (LSP fallback). |
| Which-key popup | `<leader>` | Shows contextual key hints after any prefix. |

## Files And Explorer

Neo-tree is the file explorer side panel. It follows the current file
automatically (the tree highlights the buffer you're editing).

| Name | Keys | Description |
|---|---|---|
| Focus explorer | `<leader>e` | Opens and focuses the Neo-tree file explorer. |
| Reveal current file | `<leader>E` | Focuses the tree on the file you're editing. |
| Open node | `<CR>` | Opens the file/expands the folder _(plugin default)_. |
| Vertical split | `s` | Opens selected file in a vertical split _(plugin default)_. |
| Horizontal split | `S` | Opens selected file in a horizontal split _(plugin default)_. |
| Add file/dir | `a` | Creates a file or directory _(plugin default)_. |
| Delete | `d` | Deletes the node _(plugin default)_. |
| Rename | `r` | Renames the node _(plugin default)_. |
| Toggle hidden | `H` | Shows/hides dotfiles _(plugin default)_. |
| Explorer help | `?` | Shows Neo-tree key help _(plugin default)_. |

## Search And Pickers

Telescope powers fuzzy finding.

| Name | Keys | Description |
|---|---|---|
| Find files | `<leader>ff` | Fuzzy-finds files in the working directory. |
| Live grep | `<leader>fg` | Searches file contents across the project. |
| Grep (alt) | `<leader>/` | Live grep shortcut. |
| Buffers | `<leader>fb` | Lists and switches open buffers. |
| Help tags | `<leader>fh` | Searches Neovim help. |
| Recent files | `<leader>fr` | Opens a recently edited file. |
| Projects | `<leader>fp` | Opens the project switcher (project.nvim); re-roots the tree to the chosen project. |
| Next/prev result | `<C-n>` / `<C-p>` | Moves through picker results _(plugin default)_. |
| Open in split | `<C-x>` / `<C-v>` | Opens result in horizontal/vertical split _(plugin default)_. |
| Open in tab | `<C-t>` | Opens result in a new tab _(plugin default)_. |
| Picker help | `<C-/>` | Shows Telescope mappings (insert mode) _(plugin default)_. |

## Buffers

| Name | Keys | Description |
|---|---|---|
| Next buffer | `<S-l>` | Switches to the next buffer. |
| Previous buffer | `<S-h>` | Switches to the previous buffer. |
| Delete buffer | `<leader>bd` | Closes the current buffer. |

## Windows

| Name | Keys | Description |
|---|---|---|
| Go to left window | `<C-h>` | Focuses the window to the left. |
| Go to lower window | `<C-j>` | Focuses the window below. |
| Go to upper window | `<C-k>` | Focuses the window above. |
| Go to right window | `<C-l>` | Focuses the window to the right. |
| Vertical split | `<C-w>v` | Splits the window vertically _(built-in)_. |
| Horizontal split | `<C-w>s` | Splits the window horizontally _(built-in)_. |
| Close window | `<C-w>q` | Closes the current window _(built-in)_. |

## Editing

Provided by mini.ai (text objects), mini.surround, mini.pairs and Comment.nvim.

| Name | Keys | Description |
|---|---|---|
| Toggle line comment | `gcc` | Comments/uncomments the current line _(Comment.nvim)_. |
| Toggle comment (visual) | `gc` | Comments/uncomments the selection _(Comment.nvim)_. |
| Toggle block comment | `gbc` | Toggles a block comment _(Comment.nvim)_. |
| Add surround | `sa` | Surrounds a motion/selection with a pair _(mini.surround)_. |
| Delete surround | `sd` | Deletes the surrounding pair _(mini.surround)_. |
| Replace surround | `sr` | Replaces the surrounding pair _(mini.surround)_. |
| Around/inside text object | `a` / `i` | Extended text objects, e.g. `ci(`, `daf` _(mini.ai)_. |
| Auto pairs | _(insert)_ | Automatically closes brackets/quotes _(mini.pairs)_. |

## Multicursor

Provided by multicursor.nvim (Sublime-style).

| Name | Keys | Description |
|---|---|---|
| Add cursor at next match | `<C-n>` | Adds a cursor at the next occurrence of the word/selection. |
| Add cursor above | `<C-Up>` | Adds a cursor on the line above. |
| Add cursor below | `<C-Down>` | Adds a cursor on the line below. |
| Add cursors to all matches | `<leader>A` | Places a cursor at every match in the buffer. |
| Clear cursors | `<Esc>` | Removes the extra cursors (while multicursor is active). |

## Completion

blink.cmp using the default keymap preset.

| Name | Keys | Description |
|---|---|---|
| Trigger/complete | `<C-Space>` | Opens the completion menu _(blink default)_. |
| Accept | `<CR>` | Accepts the selected item _(blink default)_. |
| Next item | `<C-n>` | Selects the next candidate _(blink default)_. |
| Previous item | `<C-p>` | Selects the previous candidate _(blink default)_. |
| Snippet forward | `<Tab>` | Jumps to the next snippet placeholder _(blink default)_. |
| Snippet backward | `<S-Tab>` | Jumps to the previous snippet placeholder _(blink default)_. |
| Hide menu | `<C-e>` | Dismisses the completion menu _(blink default)_. |

## LSP And Code Navigation

Applies to every LSP-backed language (Scala/Metals, Rust, Go, Haskell, Java,
Python, Nix, Bash, YAML, JSON, TOML, Markdown).

| Name | Keys | Description |
|---|---|---|
| Go to definition | `gd` | Jumps to the definition. |
| Go to declaration | `gD` | Jumps to the declaration. |
| Find references | `gr` | Lists references. |
| Go to implementation | `gi` | Jumps to implementations. |
| Go to type definition | `gt` | Jumps to the type definition. |
| Hover docs | `K` | Shows hover documentation. |
| Rename symbol | `<leader>cr` | Renames the symbol project-wide. |
| Code action | `<leader>ca` | Opens available code actions. |
| Line diagnostics | `<leader>cd` | Shows diagnostics for the current line. |
| Previous diagnostic | `[d` | Jumps to the previous diagnostic. |
| Next diagnostic | `]d` | Jumps to the next diagnostic. |

## Formatting

conform.nvim formats on save; also on demand.

| Name | Keys | Description |
|---|---|---|
| Format buffer | `<leader>cf` | Formats via conform (LSP fallback). |
| Format on save | _(automatic)_ | Runs on every write (3s timeout, LSP fallback). |

Formatters by filetype: Nix→alejandra, Go→goimports+gofumpt, Python→ruff,
Rust→rustfmt, Haskell→fourmolu, Scala→scalafmt, Java→google-java-format,
Shell→shfmt, YAML/JSON/Markdown→prettier, TOML→taplo.

## Diagnostics And Linting

nvim-lint runs linters on top of LSP diagnostics.

| Name | Keys | Description |
|---|---|---|
| Previous diagnostic | `[d` | Jumps to the previous diagnostic. |
| Next diagnostic | `]d` | Jumps to the next diagnostic. |
| Line diagnostics | `<leader>cd` | Opens the floating diagnostic window. |

Linters by filetype: Go→golangci-lint, Haskell→hlint, Markdown→markdownlint,
Shell→shellcheck.

## Git

gitsigns shows hunk signs in the gutter; LazyGit provides the full UI.

| Name | Keys | Description |
|---|---|---|
| Open LazyGit | `<leader>gg` | Opens LazyGit in a floating window. |
| Git hunk commands | `:Gitsigns …` | e.g. `next_hunk`, `prev_hunk`, `stage_hunk`, `preview_hunk`, `blame_line`. |

## DAP Debugging

Debugging is wired for **Go** (delve), **Python** (debugpy) and **Scala**
(Metals). Rust and Java are LSP-only (no debug adapter).

| Name | Keys | Description |
|---|---|---|
| Toggle breakpoint | `<leader>db` | Toggles a breakpoint at the cursor. |
| Continue | `<leader>dc` or `<F5>` | Starts/continues the debug session. |
| Step into | `<leader>di` or `<F11>` | Steps into the next call. |
| Step over | `<leader>do` or `<F10>` | Steps over the next statement. |
| Step out | `<leader>dO` or `<F12>` | Steps out of the current frame. |
| Terminate | `<leader>dt` | Ends the debug session. |
| Open REPL | `<leader>dr` | Opens the debug REPL. |
| Toggle DAP UI | `<leader>du` | Shows/hides the debugger UI panels. |

## Run And Build

| Name | Keys | Description |
|---|---|---|
| Cargo run | `<leader>rr` | Runs the nearest Cargo project in a floating terminal. |
| sbt client | `<leader>rs` | Opens or reopens the persistent sbt thin-client terminal for the nearest project. Active multicursors are cleared first. |
| Hide sbt client | `q` | Hides the sbt float from terminal Normal mode without stopping the client or server. |
| Hide sbt client | `<C-q>` | Hides the sbt float from Terminal mode without stopping the client or server. |

## Org mode

Org files live in `~/org`; the agenda scans `~/org/**/*` and capture writes to
`~/org/refile.org`. Rendering is enhanced by headlines.nvim (heading
highlights), and leading heading stars are hidden for a cleaner look.

Global:

| Keys | Description |
|---|---|
| `<leader>oa` | Open the agenda prompt |
| `<leader>oc` | Open the capture prompt |

In an `.org` buffer:

| Keys | Description |
|---|---|
| `g?` | Show all org-buffer mappings (help) |
| `<Tab>` / `<S-Tab>` | Fold current heading / whole file |
| `cit` / `ciT` | Cycle TODO state forward / backward |
| `<leader><CR>` | Add heading / list item / checkbox below |
| `<leader>oih` | Insert heading after the current subtree |
| `<leader>oit` / `<leader>oiT` | Insert TODO heading (after subtree / after line) |
| `<C-Space>` | Toggle checkbox |
| `<leader>oo` | Open link or date under the cursor |
| `<leader>ot` | Change tags |
| `<leader>or` | Refile the current headline |
| `<<` / `>>` | Promote / demote the headline |
| `<s` / `>s` | Promote / demote the whole subtree |
| `<leader>oK` / `<leader>oJ` | Move headline up / down |
| `<C-a>` / `<C-x>` | Increase / decrease the date under the cursor |
| `cid` | Change the date under the cursor (calendar popup) |
| `<leader>o*` | Toggle line ↔ headline |
| `<leader>o$` / `<leader>oA` | Archive subtree / add ARCHIVE tag |

In the capture buffer:

| Keys | Description |
|---|---|
| `<C-c>` | Finalize the capture to the default notes file |
| `<leader>or` | Refile the capture to a chosen destination |
| `<leader>ok` | Abort the capture |

## Language Notes

| Language | Server / Tooling | Notes |
|---|---|---|
| Scala | Metals (+ scalafmt) | Attaches on `scala`/`sbt` files; debugging via Metals + nvim-dap. |
| Rust | rust-analyzer (from rustup) + rustaceanvim | Analyzer comes from the rustup toolchain, not nixpkgs. LSP-only. |
| Go | gopls (+ gofumpt, goimports, golangci-lint) | Debugging via nvim-dap-go + delve. |
| Haskell | haskell-language-server + haskell-tools.nvim | Formatters fourmolu/ormolu; hlint linting. LSP-only. |
| Java | jdtls + nvim-jdtls (+ google-java-format) | Attaches per project root (`.git`, `pom.xml`, `build.gradle`, …). LSP-only. |
| Python | basedpyright + ruff | ruff handles lint + format; debugging via debugpy. |
| Nix | nil + nixd (+ alejandra) | Format on save with alejandra. |
| Bash | bash-language-server (+ shfmt, shellcheck) | — |
| YAML / JSON / TOML / Markdown | yaml-language-server / jsonls / taplo / marksman | prettier (yaml/json/md), taplo (toml); markdownlint for Markdown. |
| Mermaid | Treesitter only | Syntax highlighting; no language server exists. |
