{ ... }:
{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    colorscheme = "github_light";
    colorschemes.github-theme.enable = true;
    opts = { number = true; relativenumber = true; expandtab = true; shiftwidth = 2; tabstop = 2; termguicolors = true; background = "light"; };
    globals.mapleader = " ";
    plugins = {
      web-devicons.enable = true;
      telescope = { enable = true; extensions.fzf-native.enable = true; };
      treesitter = { enable = true; settings.highlight.enable = true; };
      lsp = {
        enable = true;
        servers = {
          nil_ls.enable = true;
          lua_ls.enable = true;
          ts_ls.enable = true;
          pyright.enable = true;
          rust_analyzer = { enable = true; installCargo = false; installRustc = false; };
        };
      };
      blink-cmp.enable = true;
      gitsigns.enable = true;
    };
    keymaps = [
      { mode = "n"; key = "<leader>ff"; action = "<cmd>Telescope find_files<cr>"; }
      { mode = "n"; key = "<leader>fg"; action = "<cmd>Telescope live_grep<cr>"; }
      { mode = "n"; key = "<leader>fh"; action = "<cmd>Telescope help_tags<cr>"; }
      { mode = "n"; key = "<leader>fb"; action = "<cmd>Telescope buffers<cr>"; }
      { mode = "n"; key = "gd"; action = "<cmd>lua vim.lsp.buf.definition()<cr>"; }
      { mode = "n"; key = "K"; action = "<cmd>lua vim.lsp.buf.hover()<cr>"; }
      { mode = "n"; key = "gr"; action = "<cmd>lua vim.lsp.buf.references()<cr>"; }
      { mode = "n"; key = "<leader>rn"; action = "<cmd>lua vim.lsp.buf.rename()<cr>"; }
      { mode = "n"; key = "<leader>ca"; action = "<cmd>lua vim.lsp.buf.code_action()<cr>"; }
      { mode = "n"; key = "]d"; action = "<cmd>lua vim.diagnostic.goto_next()<cr>"; }
      { mode = "n"; key = "[d"; action = "<cmd>lua vim.diagnostic.goto_prev()<cr>"; }
    ];
  };
}
