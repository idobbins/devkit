
-- init.lua


-- general

vim.o.syntax = 'on'
vim.o.number = true
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.smartindent = true
vim.o.autoindent = true

-- packer

require('packer').startup(function(use)

  use 'wbthomason/packer.nvim'

  use 'github/copilot.vim'

  use 'neovim/nvim-lspconfig'

  use { 'ms-jpq/coq_nvim', run = 'python3 -m coq deps' }
  use 'ms-jpq/coq.artifacts'
  use 'ms-jpq/coq.thirdparty'

  use 'nvim-treesitter/nvim-treesitter'

  use 'preservim/nerdtree'

  use 'nvim-tree/nvim-web-devicons'
  use {'romgrk/barbar.nvim', requires = 'nvim-web-devicons'}

  use {'nvim-lualine/lualine.nvim', requires = {'kyazdani42/nvim-web-devicons', opt = true}}

  use 'klen/nvim-config-local'

  use 'jiangmiao/auto-pairs'

end)

require('config-local').setup {
  -- Default configuration (optional)
  config_files = { ".vimrc.lua", ".vimrc" },
  hashfile = vim.fn.stdpath("data") .. "/config-local",
  autocommands_create = true,
  commands_create = true,
  silent = false,
  lookup_parents = false,
}


local lspconfig = require('lspconfig')

-- Automatically start coq
vim.g.coq_settings = { auto_start = 'shut-up' }

-- Enable some language servers with the additional completion capabilities offered by coq_nvim
local servers = { 'clangd' }

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup(require('coq').lsp_ensure_capabilities({
    -- on_attach = my_custom_on_attach,
  }))
end

-- treesitte\

require('nvim-treesitter.configs').setup {
  ensure_installed = "all",

  auto_install = true,

  highlight = {
    enable = true,
  },
}

-- lualine

require('lualine').setup()
