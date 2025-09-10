return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'stevearc/overseer.nvim',
    { 'fredrikaverpil/neotest-golang', version = '*' }, -- Installation
  },
  config = function()
    local neotest_golang = require 'neotest-golang'
    local neotest = require 'neotest'

    neotest.setup {
      adapters = {
        neotest_golang {
          go_test_args = { '-v', '-race', '-count=1', '-timeout=60s' },
          dap_go_enabled = true,
        },
      },
      discovery = {
        enabled = true,
      },
      consumers = {
        overseer = require 'neotest.consumers.overseer',
      },
      icons = {
        passed = ' ',
        running = ' ',
        failed = ' ',
        unknown = ' ',
        running_animated = vim.tbl_map(function(s)
          return s .. ' '
        end, { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }),
      },
      output = {
        open_on_run = true,
      },
    }
    vim.keymap.set('n', '<leader>tf', function()
      neotest.run.run { vim.api.nvim_buf_get_name(0) }
    end, { desc = '[T]est [F]ile' })
    vim.keymap.set('n', '<leader>tn', function()
      neotest.run.run {}
    end, { desc = '[T]est [N]earest' })
    vim.keymap.set('n', '<leader>tl', neotest.run.run_last, { desc = '[T]est [L]ast' })
    vim.keymap.set('n', '<leader>ts', neotest.summary.toggle, { desc = '[T]est toggle [S]ummary' })
    vim.keymap.set('n', '<leader>to', function()
      neotest.output.open { short = true }
    end, { desc = '[T]est [O]utput' })
  end,
}
