return {
  {
    name = "catppuccin",
    priority = 1000,
    "catppuccin/nvim",
    config = function()
      require("catppuccin").setup({
        transparent_background = true, -- disables setting the background color.
      })
    end,
  },
  -- add gruvbox
  {
    "ellisonleao/gruvbox.nvim",
    config = function()
      require("gruvbox").setup({
        contrast = "hard",
        --palette_overrides = {
        --dark0_hard = "#151522",
        --},
      })
    end,
  },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
    },
  },
}
