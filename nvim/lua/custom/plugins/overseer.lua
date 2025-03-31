return { -- Task runner
  'stevearc/overseer.nvim',
  opts = {
    templates = { 'builtin' },
    default_neotest = {
      { 'on_complete_notify', on_change = true },
      'default',
    },
  },
  config = function(_, opts)
    require('overseer').setup(opts)
    vim.keymap.set('n', '<leader>ot', '<cmd>OverseerToggle<CR>', { desc = '[O]verseer [T]oggle' })
    vim.keymap.set('n', '<leader>or', '<cmd>OverseerRun<CR>', { desc = '[O]verseer [R]un' })
    vim.keymap.set('n', '<leader>oq', '<cmd>OverseerQuickAction<CR>', { desc = '[O]verseer [Q]uick action' })
    vim.keymap.set('n', '<leader>oa', '<cmd>OverseerTaskAction<CR>', { desc = '[O]verseer task [A]ction' })
  end,
}
