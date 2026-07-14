{
  pkgs,
  lib,
  inputs,
  ...
}: let
  pythonForDap = pkgs.python3.withPackages (ps: with ps; [debugpy]);
in {
  imports = [inputs.nixvim.homeModules.nixvim];

  home.sessionVariables.EDITOR = lib.mkForce "nvim";

  home.activation.bootstrapOrgDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p "$HOME/org"
    [ -e "$HOME/org/refile.org" ] || touch "$HOME/org/refile.org"
  '';

  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    nixpkgs.pkgs = pkgs;

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      signcolumn = "yes";
      termguicolors = true;
      undofile = true;
      ignorecase = true;
      smartcase = true;
      splitright = true;
      splitbelow = true;
      scrolloff = 4;
      cursorline = true;
    };

    colorschemes.catppuccin = {
      enable = true;
      settings.flavour = "macchiato";
    };

    extraPackages = with pkgs; [
      metals
      scalafmt
      gofumpt
      gotools
      golangci-lint
      delve
      pythonForDap
      haskell-language-server
      ormolu
      haskellPackages.fourmolu
      stylish-haskell
      hlint
      jdt-language-server
      google-java-format
      alejandra
      shfmt
      shellcheck
      yamlfmt
      mdformat
      markdownlint-cli
      lazygit
    ];

    keymaps = [
      {
        mode = "n";
        key = "<leader>w";
        action = "<cmd>w<cr>";
        options.desc = "Save file";
      }
      {
        mode = "n";
        key = "<leader>q";
        action = "<cmd>q<cr>";
        options.desc = "Quit window";
      }
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Neotree focus<cr>";
        options.desc = "Focus explorer (neo-tree)";
      }
      {
        mode = "n";
        key = "<leader>E";
        action = "<cmd>Neotree reveal<cr>";
        options.desc = "Reveal current file in explorer";
      }
      {
        mode = "n";
        key = "<leader>fp";
        action = "<cmd>Telescope projects<cr>";
        options.desc = "Projects";
      }
      {
        mode = "n";
        key = "<S-h>";
        action = "<cmd>bprevious<cr>";
        options.desc = "Previous buffer";
      }
      {
        mode = "n";
        key = "<S-l>";
        action = "<cmd>bnext<cr>";
        options.desc = "Next buffer";
      }
      {
        mode = "n";
        key = "<leader>bd";
        action = "<cmd>bdelete<cr>";
        options.desc = "Delete buffer";
      }
      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w>h";
        options.desc = "Go to left window";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<C-w>j";
        options.desc = "Go to lower window";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<C-w>k";
        options.desc = "Go to upper window";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w>l";
        options.desc = "Go to right window";
      }
      {
        mode = "n";
        key = "<leader>gg";
        action = "<cmd>LazyGit<cr>";
        options.desc = "LazyGit";
      }
      {
        mode = "n";
        key = "<leader>cf";
        action.__raw = "function() require('conform').format({ async = true, lsp_format = 'fallback' }) end";
        options.desc = "Format buffer";
      }
    ];

    plugins = {
      web-devicons.enable = true;
      lualine.enable = true;
      bufferline.enable = true;
      which-key.enable = true;
      gitsigns.enable = true;
      comment.enable = true;

      telescope = {
        enable = true;
        keymaps = {
          "<leader>ff" = "find_files";
          "<leader>fg" = "live_grep";
          "<leader>fb" = "buffers";
          "<leader>fh" = "help_tags";
          "<leader>fr" = "oldfiles";
          "<leader>/" = "live_grep";
        };
      };

      neo-tree = {
        enable = true;
        settings.filesystem = {
          follow_current_file.enabled = true;
          use_libuv_file_watcher = true;
        };
      };

      project-nvim.enable = true;

      orgmode = {
        enable = true;
        settings = {
          org_agenda_files = "~/org/**/*";
          org_default_notes_file = "~/org/refile.org";
          org_hide_leading_stars = true;
        };
      };

      mini = {
        enable = true;
        modules = {
          ai = {};
          pairs = {};
          surround = {};
        };
      };

      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
      };

      blink-cmp = {
        enable = true;
        settings = {
          keymap.preset = "default";
          sources.default = ["lsp" "path" "snippets" "buffer"];
        };
      };

      lsp = {
        enable = true;
        servers = {
          nil_ls.enable = true;
          nixd.enable = true;
          gopls.enable = true;
          basedpyright.enable = true;
          ruff.enable = true;
          bashls.enable = true;
          yamlls.enable = true;
          jsonls.enable = true;
          taplo.enable = true;
          marksman.enable = true;
        };
        keymaps = {
          lspBuf = {
            "gd" = "definition";
            "gD" = "declaration";
            "gr" = "references";
            "gi" = "implementation";
            "gt" = "type_definition";
            "K" = "hover";
            "<leader>cr" = "rename";
            "<leader>ca" = "code_action";
          };
          diagnostic = {
            "<leader>cd" = "open_float";
            "[d" = "goto_prev";
            "]d" = "goto_next";
          };
        };
      };

      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            nix = ["alejandra"];
            go = ["goimports" "gofumpt"];
            python = ["ruff_format"];
            rust = ["rustfmt"];
            haskell = ["fourmolu"];
            scala = ["scalafmt"];
            java = ["google-java-format"];
            sh = ["shfmt"];
            bash = ["shfmt"];
            yaml = ["yamlfmt"];
            markdown = ["mdformat"];
            toml = ["taplo"];
          };
          format_on_save = {
            timeout_ms = 3000;
            lsp_format = "fallback";
          };
        };
      };

      lint = {
        enable = true;
        lintersByFt = {
          go = ["golangcilint"];
          haskell = ["hlint"];
          markdown = ["markdownlint"];
          sh = ["shellcheck"];
          bash = ["shellcheck"];
        };
      };

      dap = {
        enable = true;
        signs.dapBreakpoint.text = "●";
      };
      dap-ui.enable = true;
      dap-virtual-text.enable = true;
      dap-go.enable = true;
      dap-python.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; [
      plenary-nvim
      nvim-metals
      rustaceanvim
      haskell-tools-nvim
      nvim-jdtls
      lazygit-nvim
      multicursor-nvim
      headlines-nvim
      opencode-nvim
      render-markdown-nvim
    ];

    extraConfigLua = ''
      local metals_config = require("metals").bare_config()
      metals_config.settings = { showImplicitArguments = true, useGlobalExecutable = true }
      metals_config.init_options.statusBarProvider = "off"
      local metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "scala", "sbt" },
        callback = function()
          require("metals").initialize_or_attach(metals_config)
        end,
        group = metals_group,
      })

      local jdtls_group = vim.api.nvim_create_augroup("nvim-jdtls", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "java" },
        callback = function()
          local markers = vim.fs.find(
            { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" },
            { upward = true }
          )
          local root_dir = markers[1] and vim.fs.dirname(markers[1]) or vim.loop.cwd()
          require("jdtls").start_or_attach({
            cmd = { "jdtls" },
            root_dir = root_dir,
          })
        end,
        group = jdtls_group,
      })

      local dap = require("dap")
      local dapui = require("dapui")
      local map = vim.keymap.set
      map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
      map("n", "<leader>dc", dap.continue, { desc = "Continue" })
      map("n", "<leader>di", dap.step_into, { desc = "Step into" })
      map("n", "<leader>do", dap.step_over, { desc = "Step over" })
      map("n", "<leader>dO", dap.step_out, { desc = "Step out" })
      map("n", "<leader>dt", dap.terminate, { desc = "Terminate" })
      map("n", "<leader>dr", dap.repl.open, { desc = "Open REPL" })
      map("n", "<leader>du", dapui.toggle, { desc = "Toggle DAP UI" })
      map("n", "<F5>", dap.continue, { desc = "Continue" })
      map("n", "<F10>", dap.step_over, { desc = "Step over" })
      map("n", "<F11>", dap.step_into, { desc = "Step into" })
      map("n", "<F12>", dap.step_out, { desc = "Step out" })

      local mc = require("multicursor-nvim")
      mc.setup()
      vim.keymap.set({ "n", "x" }, "<C-n>", function()
        mc.matchAddCursor(1)
      end, { desc = "Multicursor: add cursor at next match" })
      vim.keymap.set({ "n", "x" }, "<C-Up>", function()
        mc.lineAddCursor(-1)
      end, { desc = "Multicursor: add cursor above" })
      vim.keymap.set({ "n", "x" }, "<C-Down>", function()
        mc.lineAddCursor(1)
      end, { desc = "Multicursor: add cursor below" })
      vim.keymap.set({ "n", "x" }, "<leader>A", function()
        mc.matchAllAddCursors()
      end, { desc = "Multicursor: add cursors to all matches" })
      mc.addKeymapLayer(function(layerSet)
        layerSet({ "n", "x" }, "<esc>", function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          elseif mc.hasCursors() then
            mc.clearCursors()
          end
        end)
      end)

      pcall(function()
        require("telescope").load_extension("projects")
      end)

      require("headlines").setup()

      require("render-markdown").setup({
        anti_conceal = { enabled = false },
        file_types = { "markdown", "opencode_output" },
      })

      local function cargo_run()
        local bufname = vim.api.nvim_buf_get_name(0)
        local start_dir = bufname ~= "" and vim.fs.dirname(bufname) or vim.loop.cwd()
        local found = vim.fs.find({ "Cargo.toml" }, { upward = true, path = start_dir })
        if not found[1] then
          vim.notify("cargo run: no Cargo.toml found upward from " .. start_dir, vim.log.levels.ERROR, { title = "cargo" })
          return
        end
        local root = vim.fs.dirname(found[1])
        local src_win = vim.api.nvim_get_current_win()

        local width = math.floor(vim.o.columns * 0.8)
        local height = math.floor(vim.o.lines * 0.7)
        local buf = vim.api.nvim_create_buf(false, true)
        local win = vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          width = width,
          height = height,
          row = math.floor((vim.o.lines - height) / 2),
          col = math.floor((vim.o.columns - width) / 2),
          style = "minimal",
          border = "rounded",
          title = " cargo run ",
          title_pos = "center",
        })

        local closed = false
        local function close()
          if closed then
            return
          end
          closed = true
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
          end
          if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
          if vim.api.nvim_win_is_valid(src_win) then
            vim.api.nvim_set_current_win(src_win)
          end
        end

        local job = vim.fn.jobstart({ "cargo", "run" }, {
          cwd = root,
          term = true,
          on_exit = function()
            if vim.api.nvim_get_current_buf() == buf then
              vim.cmd("stopinsert")
            end
            for _, mode in ipairs({ "n", "t" }) do
              vim.keymap.set(mode, "q", close, { buffer = buf, nowait = true, desc = "cargo run: close output" })
            end
          end,
        })

        if job <= 0 then
          vim.notify("cargo run: failed to start (is cargo on PATH?)", vim.log.levels.ERROR, { title = "cargo" })
          close()
          return
        end

        vim.cmd("startinsert")
      end

      vim.keymap.set("n", "<leader>rr", cargo_run, { desc = "Cargo run (floating)" })
    '';
  };
}
