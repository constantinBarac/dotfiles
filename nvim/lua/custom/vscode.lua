require 'custom.set'
require 'custom.remap'
require 'kickstart.remap'

local vscode = require 'vscode'

vim.keymap.set('n', 'gd', function()
  vscode.action 'editor.action.revealDefinition'
end, { desc = 'Go to definition' })

vim.keymap.set('n', 'gr', function()
  vscode.action 'editor.action.goToReferences'
end, { desc = 'Go to references' })

vim.keymap.set('n', 'gi', function()
  vscode.action 'editor.action.goToImplementation'
end, { desc = 'Go to implementation' })

vim.keymap.set('n', ']g', function()
  vscode.action 'workbench.action.editor.nextChange'
end, { desc = 'Next git change' })

vim.keymap.set('n', '[g', function()
  vscode.action 'workbench.action.editor.previousChange'
end, { desc = 'Previous git change' })

vim.keymap.set('n', ']d', function()
  vscode.action 'editor.action.marker.nextInFiles'
end, { desc = 'Next diagnostic' })

vim.keymap.set('n', '[d', function()
  vscode.action 'editor.action.marker.prevInFiles'
end, { desc = 'Previous diagnostic' })

vim.keymap.set('n', '<C-u>', '24kzz')
vim.keymap.set('n', '<C-d>', '24jzz')

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  {
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
