-- ===========================
-- UI Components
-- ===========================
return {
  {
    'willothy/nvim-cokeline',
    commit = '9fbed13',
  },
  {
    'goolord/alpha-nvim',
    commit = '3979b01',
    event = 'VimEnter',
    dependencies = {
      'MaximilianLloyd/ascii.nvim',
      commit = '70783fe',
    },
  },
  {
    'stevearc/dressing.nvim',
    commit = '3a45525',
    event = 'VeryLazy',
  },
  {
    'rcarriga/nvim-notify',
    commit = 'a3020c2',
    event = 'VeryLazy',
  },
  {
    'beauwilliams/focus.nvim',
    commit = '4135f97',
    cmd = { 'FocusSplitNicely', 'FocusSplitCycle', 'FocusToggle' },
  },
}
