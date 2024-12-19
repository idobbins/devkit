-- Install Lazy.nvim if not already installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Configure Lazy.nvim
require('lazy').setup({
  'kyazdani42/nvim-web-devicons',

  -- Telescope configuration remains the same
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.4',
    dependencies = { 'nvim-lua/plenary.nvim', 'kyazdani42/nvim-web-devicons' },
  },
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
  },

  -- Updated Treesitter configuration
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = { "lua", "vim", "vimdoc", "query", "haskell", "python", "javascript", "typescript", "c", "cpp" },
        auto_install = false,  -- Disable auto_install since we're using Nix
        highlight = {
          enable = true,
        },
      })
    end,
  },

  -- Lazygit configuration remains the same
  {
    'kdheepak/lazygit.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },

  -- Updated LSP configuration
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    dependencies = {
      -- LSP Support
      'neovim/nvim-lspconfig',
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Autocompletion
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lua',

      -- Snippets
      'L3MON4D3/LuaSnip',
      'rafamadriz/friendly-snippets',
    }
  },

  -- Other plugins remain the same
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'kyazdani42/nvim-web-devicons' },
  },
  'stevearc/dressing.nvim',
  'rcarriga/nvim-notify',
  'klen/nvim-config-local',
  {
    'folke/trouble.nvim',
    dependencies = { 'kyazdani42/nvim-web-devicons' },
    config = function()
      require("trouble").setup {
        icons = true,
      }
    end
  },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 }
})

-- General settings remain the same
vim.g.mapleader = " "
vim.o.syntax = 'on'
vim.o.number = true
vim.o.relativenumber = true
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.smartindent = true
vim.o.autoindent = true
vim.o.termguicolors = true
vim.o.splitright = true

require("catppuccin").setup({
    flavour = "macchiato", -- Choose your preferred flavor: latte, frappe, macchiato, mocha
    term_colors = true,
    color_overrides = {},
})

vim.opt.termguicolors = true
vim.cmd.colorscheme "catppuccin"

vim.keymap.set('n', '<leader>m', '<cmd>:marks<CR>', {})

-- nvim-config-local configuration remains the same
require('config-local').setup {
  config_files = { ".vimrc.lua" },
  hashfile = vim.fn.stdpath("data") .. "/config-local",
  autocommands_create = true,
  commands_create = true,
  silent = false,
  lookup_parents = true,
}

-- Telescope configuration
local telescope = require('telescope')
local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>fr', builtin.lsp_references, {})

telescope.setup {
  defaults = {
    file_ignore_patterns = {"node_modules"},
    path_display = { "truncate" },
    winblend = 0,
    layout_strategy = "horizontal",
    sorting_strategy = "ascending",
    layout_config = {
      horizontal = {
        prompt_position = "top",
        preview_width = 0.55,
        results_width = 0.8,
      },
      width = 0.87,
      height = 0.80,
      preview_cutoff = 120,
    },
    mappings = {
      n = { ["q"] = require("telescope.actions").close },
    },
  },
}
telescope.load_extension('fzf')

-- Updated LSP configuration
local lsp_zero = require('lsp-zero')
lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
  local opts = {buffer = bufnr, remap = false}

  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
end)

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {
    'bashls',
    'clangd',
    'cmake',
    'csharp_ls',
    'emmet_ls',
    'hls',
    'pyright',
    'rust_analyzer',
    'tailwindcss',
    'ts_ls',
    'terraformls',
  },
  handlers = {
    lsp_zero.default_setup,
    lua_ls = function()
      local lua_opts = lsp_zero.nvim_lua_ls()
      require('lspconfig').lua_ls.setup(lua_opts)
    end,
  }
})

-- Updated completion configuration
local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}

cmp.setup({
  sources = {
    {name = 'path'},
    {name = 'nvim_lsp'},
    {name = 'nvim_lua'},
    {name = 'buffer', keyword_length = 3},
    {name = 'luasnip', keyword_length = 2},
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ['<C-Space>'] = cmp.mapping.complete(),
  }
})

-- Diagnostic configuration
vim.diagnostic.config({
  virtual_text = true
})

-- Lualine configuration
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
  }
}

-- Tailwind CSS configuration
require('lspconfig').tailwindcss.setup {
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "haskell" },
  init_options = {
    userLanguages = {
      haskell = "html"
    }
  },
  settings = {
    tailwindCSS = {
      experimental = {
        classRegex = {
          "class_\\s*[\"']([^\"']*)[\"']"
        }
      }
    }
  }
}
