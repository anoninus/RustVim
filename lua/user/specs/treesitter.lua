-- ===========================
-- Treesitter (load on file open)
-- ===========================
return {
  {
    'nvim-treesitter/nvim-treesitter',
    event = 'BufReadPre',
    build = ':TSUpdate',
  },
}
