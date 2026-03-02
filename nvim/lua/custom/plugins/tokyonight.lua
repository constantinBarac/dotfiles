return {
  'folke/tokyonight.nvim',
  priority = 1000,
  opts = {
    style = 'night',
    transparent = true,
    styles = {
      sidebars = 'transparent',
      floats = 'transparent',
    },
  },
  init = function()
    vim.cmd.colorscheme 'tokyonight'
  end,
}
