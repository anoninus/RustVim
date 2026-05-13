-- ===========================
-- DAP (Debug Adapter Protocol)
-- ===========================
return {
  {
    'mfussenegger/nvim-dap',
    commit = '6a5bba0',
    cmd = { 'DapContinue', 'DapToggleBreakpoint', 'DapStepOver', 'DapStepInto', 'DapStepOut' },
  },
  {
    'rcarriga/nvim-dap-ui',
    commit = 'cf91d5e',
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-neotest/nvim-nio',
    },
    cmd = { 'DapContinue', 'DapToggleBreakpoint' },
  },
  {
    'theHamsta/nvim-dap-virtual-text',
    commit = 'fbdb48c',
    dependencies = { 'mfussenegger/nvim-dap' },
    event = 'LspAttach',
  },
}
