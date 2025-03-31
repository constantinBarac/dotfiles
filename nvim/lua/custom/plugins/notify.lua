return {
  'rcarriga/nvim-notify',
  opts = {
    stages = 'fade',
    render = 'minimal',
    top_down = false,
  },
  config = function(_, opts)
    local notify = require 'notify'
    notify.setup(opts)
    vim.notify = notify
  end,
}
