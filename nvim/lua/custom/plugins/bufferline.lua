return {
  'akinsho/bufferline.nvim',
  opts = {
    options = {
      diagnostics = 'nvim_lsp',
      offsets = {
        {
          filetype = 'NvimTree',
          text = 'Explorer',
          highlight = 'PanelHeading',
          padding = 1,
        },
      },
    },
  },
  config = function(_, opts)
    require('bufferline').setup(opts)
    vim.keymap.set('n', 'go', '<cmd>BufferLinePick<CR>', { desc = '[G]oto [O]pen buffer' })
  end,
}
