-- Leader (must be set before plugins load)
vim.g.mapleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
  "kyazdani42/nvim-web-devicons",

  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.4",
    dependencies = { "nvim-lua/plenary.nvim", "kyazdani42/nvim-web-devicons" },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          file_ignore_patterns = { "node_modules" },
          path_display = { "truncate" },
          layout_strategy = "horizontal",
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = { prompt_position = "top", preview_width = 0.55 },
            width = 0.87,
            height = 0.80,
          },
          mappings = { n = { ["q"] = require("telescope.actions").close } },
        },
      })
      telescope.load_extension("fzf")
    end,
  },

  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
  },

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "lua", "vim", "vimdoc", "query", "haskell", "python", "javascript", "typescript", "c", "cpp" },
      auto_install = false,
      highlight = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  { "kdheepak/lazygit.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",

  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-nvim-lua",
  "saadparwaiz1/cmp_luasnip",
  "L3MON4D3/LuaSnip",
  "rafamadriz/friendly-snippets",

  { "nvim-lualine/lualine.nvim", dependencies = { "kyazdani42/nvim-web-devicons" }, opts = { options = { icons_enabled = true, theme = "auto" } } },

  "stevearc/dressing.nvim",
  "rcarriga/nvim-notify",

  {
    "klen/nvim-config-local",
    opts = {
      config_files = { ".vimrc.lua" },
      hashfile = vim.fn.stdpath("data") .. "/config-local",
      autocommands_create = true,
      commands_create = true,
      silent = false,
      lookup_parents = true,
    },
  },

  {
    "folke/trouble.nvim",
    dependencies = { "kyazdani42/nvim-web-devicons" },
    opts = { icons = true },
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = { flavour = "macchiato", term_colors = true },
  },

  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
    end,
  },
})

-- Options
vim.opt.syntax = "on"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.termguicolors = true
vim.opt.splitright = true

-- Colorscheme
vim.cmd.colorscheme("catppuccin")

-- Keymaps
local map = vim.keymap.set
map("n", "<leader>m", "<cmd>marks<CR>")
map("n", "<leader>ff", function() require("telescope.builtin").find_files() end)
map("n", "<leader>fg", function() require("telescope.builtin").live_grep() end)
map("n", "<leader>fh", function() require("telescope.builtin").help_tags() end)
map("n", "<leader>fr", function() require("telescope.builtin").lsp_references() end)

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf }
    map("n", "gd", vim.lsp.buf.definition, opts)
    map("n", "K", vim.lsp.buf.hover, opts)
    map("n", "[d", vim.diagnostic.goto_next, opts)
    map("n", "]d", vim.diagnostic.goto_prev, opts)
    map("n", "gr", vim.lsp.buf.references, opts)
    map("n", "<leader>rn", vim.lsp.buf.rename, opts)
    map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  end,
})

-- LSP servers (single source of truth)
local servers = {
  bashls = {},
  clangd = {},
  cmake = {},
  emmet_ls = {},
  pyright = {},
  rust_analyzer = {},
  ts_ls = {},
  terraformls = {},
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file("", true) },
        telemetry = { enable = false },
      },
    },
  },
  tailwindcss = {
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "haskell" },
    init_options = { userLanguages = { haskell = "html" } },
    settings = { tailwindCSS = { experimental = { classRegex = { [=[class_\s*["']([^"']*)["']]=] } } } },
  },
}

require("mason").setup()
require("mason-lspconfig").setup({ ensure_installed = vim.tbl_keys(servers) })

local capabilities = require("cmp_nvim_lsp").default_capabilities()
for server, config in pairs(servers) do
  vim.lsp.config(server, vim.tbl_extend("force", { capabilities = capabilities }, config))
  vim.lsp.enable(server)
end

-- Completion
local cmp = require("cmp")
cmp.setup({
  sources = {
    { name = "path" },
    { name = "nvim_lsp" },
    { name = "nvim_lua" },
    { name = "vim-dadbod-completion" },
    { name = "buffer", keyword_length = 3 },
    { name = "luasnip", keyword_length = 2 },
  },
  mapping = {
    ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
    ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
    ["<C-y>"] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
  },
})

-- Diagnostics
vim.diagnostic.config({ virtual_text = true })
