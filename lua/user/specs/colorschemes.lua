-- ===========================
-- Colorschemes (all lazy loaded)
-- ===========================
return {
  {
    'catppuccin/nvim',
    commit = 'beaf41a',
  },
  {
    'folke/tokyonight.nvim',
    commit = '5da1b76',
    lazy = false,    -- important for colorschemes
    priority = 1000, -- ensure it loads first

    opts = {
      styles = {
        comments  = { italic = false },
        keywords  = { italic = false },
        functions = { italic = false },
        variables = { italic = false },
      },
      sidebars = 'dark',
      floats = 'dark',
    },

    config = function(_, opts)
      require('tokyonight').setup(opts)
      vim.cmd.colorscheme('tokyonight-night')
    end,
  },
}
