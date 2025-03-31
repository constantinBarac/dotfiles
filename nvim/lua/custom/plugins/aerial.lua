return { -- Code outline
  'stevearc/aerial.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('aerial').setup()
    vim.keymap.set('n', '<leader>a', '<cmd>AerialToggle!<CR>', { desc = '[A]erial toggle' })
    vim.keymap.set({ 'n', 'v' }, '[s', '<cmd>AerialPrev<CR>', { desc = 'Previous aerial symbol' })
    vim.keymap.set({ 'n', 'v' }, ']s', '<cmd>AerialNext<CR>', { desc = 'Next aerial symbol' })
    vim.keymap.set({ 'n', 'v' }, '[S', '<cmd>AerialPrevUp<CR>', { desc = 'Previous aerial parent symbol' })
    vim.keymap.set({ 'n', 'v' }, ']S', '<cmd>AerialNextUp<CR>', { desc = 'Next aerial parent symbol' })
  end,
}
