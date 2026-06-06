vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.o.showmode = false
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = "yes"
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.o.inccommand = "split"
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.o.wrap = false

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "\\", ":Neotree<CR>", { desc = "Open Neotree pane." })

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  pattern = { "*.lua" },
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.expandtab = true
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
  end,
})

local gh = function(relurl)
  return { src = "https://github.com/" .. relurl }
end
local packdir = vim.fn.stdpath("data") .. "/site/pack/core/opt/"

vim.pack.add({ gh("folke/tokyonight.nvim") })
local success, result = pcall(require, "tokyonight")
if success then
  result.setup({
    on_colors = function() end,
    on_highlights = function() end,
    styles = {
      comments = { italic = false }, -- Disable italics in comments
    },
  })
  vim.cmd.colorscheme("tokyonight-night")
else
  vim.notify("Failed to setup tokyonight-night", vim.log.levels.ERROR)
end

vim.pack.add({ gh("lewis6991/gitsigns.nvim") })
success, result = pcall(require, "gitsigns")
if success then
  result.setup({
    signs = {
      add = { text = "+" },
      change = { text = "~" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
    },
  })
else
  vim.notify("Failed to setup gitsigns", vim.log.levels.ERROR)
end

vim.pack.add({ gh("folke/which-key.nvim") })
vim.api.nvim_create_autocmd({ "VimEnter" }, {
  desc = "Configure 'Which-Key' on VimEnter",
  callback = function()
    require("which-key").setup({
      delay = 0,
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = "<Up> ",
          Down = "<Down> ",
          Left = "<Left> ",
          Right = "<Right> ",
          C = "<C-…> ",
          M = "<M-…> ",
          D = "<D-…> ",
          S = "<S-…> ",
          CR = "<CR> ",
          Esc = "<Esc> ",
          ScrollWheelDown = "<ScrollWheelDown> ",
          ScrollWheelUp = "<ScrollWheelUp> ",
          NL = "<NL> ",
          BS = "<BS> ",
          Space = "<Space> ",
          Tab = "<Tab> ",
          F1 = "<F1>",
          F2 = "<F2>",
          F3 = "<F3>",
          F4 = "<F4>",
          F5 = "<F5>",
          F6 = "<F6>",
          F7 = "<F7>",
          F8 = "<F8>",
          F9 = "<F9>",
          F10 = "<F10>",
          F11 = "<F11>",
          F12 = "<F12>",
        },
      },

      spec = {
        { "<leader>s", group = "[S]earch" },
        { "<leader>t", group = "[T]oggle" },
        { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
      },
    })
  end,
})

-- Telescope dependencies
vim.pack.add({
  gh("nvim-lua/plenary.nvim"),
  gh("nvim-telescope/telescope-fzf-native.nvim"),
  gh("nvim-telescope/telescope-ui-select.nvim"),
  gh("nvim-tree/nvim-web-devicons"),
})

success, _ = pcall(function()
  local repo = packdir .. "telescope-fzf-native.nvim/"
  local stat = vim.uv.fs_stat(repo .. ".built")
  if stat == nil then
    local obj = vim.system({ "make" }, { cwd = repo }):wait()
    if obj.code ~= 0 then
      vim.notify("Failed to run make in " .. repo, vim.log.levels.ERROR)
    else
      vim.notify("Built telescope-fzf-native.nvim!", vim.log.levels.INFO)
      vim.system({ "touch", ".built" }, { cwd = repo }):wait()
    end
  end
end)

if not success then
  vim.notify("Failed to build telescope-fzf-native.nvim", vim.log.levels.INFO)
end

vim.pack.add({
  gh("nvim-telescope/telescope.nvim"),
})

vim.api.nvim_create_autocmd({ "VimEnter" }, {
  desc = "Startup for telescope",
  callback = function()
    require("telescope").setup({
      defaults = {
        file_ignore_patterns = {
          "^.git/",
          "/.git/",
          "^deps/",
          "/deps/",
        },
      },
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown(),
        },
      },
    })
    pcall(require("telescope").load_extension, "fzf")
    pcall(require("telescope").load_extension, "ui-select")

    -- See `:help telescope.builtin`
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
    vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
    vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
    vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
    vim.keymap.set("n", "<leader>sc", builtin.commands, { desc = "[S]earch [C]ommands Telescope" })
    vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
    vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
    vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
    vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
    vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set("n", "<leader>sy", builtin.lsp_document_symbols, { desc = "[S]earch document symbols" })
    vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

    -- Slightly advanced example of overriding default behavior and theme
    vim.keymap.set("n", "<leader>/", function()
      -- You can pass additional configuration to Telescope to change the theme, layout, etc.
      builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
        winblend = 10,
        previewer = false,
      }))
    end, { desc = "[/] Fuzzily search in current buffer" })

    -- It's also possible to pass additional configuration options.
    --  See `:help telescope.builtin.live_grep()` for information about particular keys
    vim.keymap.set("n", "<leader>s/", function()
      builtin.live_grep({
        grep_open_files = true,
        prompt_title = "Live Grep in Open Files",
      })
    end, { desc = "[S]earch [/] in Open Files" })

    -- Shortcut for searching your Neovim configuration files
    vim.keymap.set("n", "<leader>sn", function()
      builtin.find_files({ cwd = vim.fn.stdpath("config") })
    end, { desc = "[S]earch [N]eovim files" })
  end,
})

vim.pack.add({ gh("neovim/nvim-lspconfig") })
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      mode = mode or "n"
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end

    -- Rename the variable under your cursor.
    --  Most Language Servers support renaming across files, etc.
    map("grn", vim.lsp.buf.rename, "[R]e[n]ame")

    -- Execute a code action, usually your cursor needs to be on top of an error
    -- or a suggestion from your LSP for this to activate.
    map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

    -- Find references for the word under your cursor.
    map("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

    -- Jump to the implementation of the word under your cursor.
    --  Useful when your language has ways of declaring types without an actual implementation.
    map("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

    -- Jump to the definition of the word under your cursor.
    --  This is where a variable was first declared, or where a function is defined, etc.
    --  To jump back, press <C-t>.
    map("grd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

    -- WARN: This is not Goto Definition, this is Goto Declaration.
    --  For example, in C this would take you to the header.
    map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

    -- Fuzzy find all the symbols in your current document.
    --  Symbols are things like variables, functions, types, etc.
    map("gO", require("telescope.builtin").lsp_document_symbols, "Open Document Symbols")

    -- Fuzzy find all the symbols in your current workspace.
    --  Similar to document symbols, except searches over your entire project.
    map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open Workspace Symbols")

    -- Jump to the type of the word under your cursor.
    --  Useful when you're not sure what type a variable is and you want to see
    --  the definition of its *type*, not where it was *defined*.
    map("grt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")

    -- The following two autocommands are used to highlight references of the
    -- word under your cursor when your cursor rests there for a little while.
    --    See `:help CursorHold` for information about when this is executed
    --
    -- When you move your cursor, the highlights will be cleared (the second autocommand).
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd("LspDetach", {
        group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
        end,
      })
    end

    -- The following code creates a keymap to toggle inlay hints in your
    -- code, if the language server you are using supports them
    --
    -- This may be unwanted, since they displace some of your code
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
      map("<leader>th", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
      end, "[T]oggle Inlay [H]ints")
    end
  end,
})

-- Diagnostic Config
-- See :help vim.diagnostic.Opts
vim.diagnostic.config({
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.INFO] = "󰋽 ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
    },
  } or {},
  virtual_text = {
    source = "if_many",
    spacing = 2,
    format = function(diagnostic)
      local diagnostic_message = {
        [vim.diagnostic.severity.ERROR] = diagnostic.message,
        [vim.diagnostic.severity.WARN] = diagnostic.message,
        [vim.diagnostic.severity.INFO] = diagnostic.message,
        [vim.diagnostic.severity.HINT] = diagnostic.message,
      }
      return diagnostic_message[diagnostic.severity]
    end,
  },
})

vim.pack.add({ gh("mason-org/mason.nvim") })
success, result = pcall(require, "mason")
if success then
  result.setup()
else
  vim.notify("Failed to setup mason", vim.log.levels.ERROR)
end

vim.pack.add({ gh("mason-org/mason-lspconfig.nvim") })
local servers = {
  pyright = {},
  -- Some languages (like typescript) have entire language plugins that can be useful:
  --    https://github.com/pmizio/typescript-tools.nvim
  --
  -- But for many setups, the LSP (`ts_ls`) will work just fine
  ts_ls = {},
  lua_ls = {
    settings = {
      Lua = {
        completion = {
          callSnippet = "Replace",
        },
      },
    },
  },
}
success, result = pcall(require, "mason-lspconfig")
if success then
  result.setup({
    ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
    automatic_installation = false,
    handlers = {
      function(server_name)
        local capabilities = require("blink.cmp").get_lsp_capabilities()
        local server = servers[server_name] or {}
        -- This handles overriding only values explicitly passed
        -- by the server configuration above. Useful when disabling
        -- certain features of an LSP (for example, turning off formatting for ts_ls)
        server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
        require("lspconfig")[server_name].setup(server)
      end,
    },
  })
else
  vim.notify("Failed to setup mason-lspconfig", vim.log.levels.ERROR)
end

vim.pack.add({
  gh("WhoIsSethDaniel/mason-tool-installer.nvim"),
})
success, result = pcall(require, "mason-tool-installer")
if success then
  local ensure_installed = vim.tbl_keys(servers or {})
  vim.list_extend(ensure_installed, {
    "stylua", -- Used to format Lua code
    "copilot",
  })
  result.setup({ ensure_installed = ensure_installed })
else
  vim.notify("Failed to setup mason-tool-installer", vim.log.levels.ERROR)
end

vim.pack.add({ gh("j-hui/fidget.nvim") })
success, result = pcall(require, "fidget")
if success then
  result.setup({})
else
  vim.notify("Failed to setup fidget", vim.log.levels.ERROR)
end

vim.pack.add({ gh("stevearc/conform.nvim") })
success, result = pcall(require, "conform")
if success then
  result.setup({
    notify_on_error = false,
    format_on_save = function(bufnr)
      local disable_filetypes = { c = true, cpp = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      else
        return {
          timeout_ms = 500,
          lsp_format = "fallback",
        }
      end
    end,
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "isort", "black" },
      javascript = { "prettierd", "prettier", stop_after_first = true },
      typescript = { "prettierd", "prettier", stop_after_first = true },
    },
  })
  local format_code = function()
    result.format({ async = true, lsp_format = "fallback" })
  end
  vim.keymap.set("", "<leader>f", format_code, { desc = "[F]ormat buffer" })
else
  vim.notify("Failed to setup conform", vim.log.levels.ERROR)
end

vim.pack.add({ gh("nvim-mini/mini.nvim") })
vim.api.nvim_create_autocmd({ "VimEnter" }, {
  desc = "Configure the mini library.",
  callback = function()
    require("mini.ai").setup({ n_lines = 500 })
    require("mini.surround").setup()
    require("mini.git").setup()
    require("mini.test").setup()

    vim.keymap.set("n", "<leader>rt", ":lua MiniTest.run()<CR>", { desc = "Run all tests in current plugin." })

    local statusline = require("mini.statusline")
    statusline.setup({ use_icons = vim.g.have_nerd_font })

    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_location = function()
      return "%2l:%-2v"
    end
  end,
})

vim.pack.add({ gh("folke/lazydev.nvim") })
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "lua",
  callback = function()
    success, result = pcall(require, "lazydev")
    if success then
      result.setup({
        library = {
          -- Load luvit types when the `vim.uv` word is found
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      })
    end
  end,
})

vim.pack.add({ { src = "https://github.com/saghen/blink.cmp", version = "v1.5.0" } })
success, result = pcall(require, "blink.cmp")
if success then
  result.setup({
    keymap = {
      preset = "default",
    },
    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = "mono",
    },
    completion = {
      -- By default, you may press `<c-space>` to show the documentation.
      -- Optionally, set `auto_show = true` to show the documentation after a delay.
      documentation = { auto_show = false, auto_show_delay_ms = 500 },
    },
    sources = {
      default = { "lsp", "path", "snippets", "lazydev" },
      providers = {
        lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
      },
    },
    fuzzy = { implementation = "lua" },
    signature = { enabled = true },
  })
else
  vim.notify("Failed to setup blink.cmp", vim.log.levels.ERROR)
end

vim.pack.add({
  {
    src = "https://github.com/nvim-neo-tree/neo-tree.nvim",
    version = vim.version.range("3"),
  },
  "https://github.com/MunifTanjim/nui.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",
})
success, result = pcall(require, "neo-tree")
if success then
  result.setup({
    filesystem = {
      window = {
        mappings = {
          ["\\"] = "close_window",
        },
      },
    },
  })
else
  vim.notify("Failed to setup neo-tree", vim.log.levels.ERROR)
end
