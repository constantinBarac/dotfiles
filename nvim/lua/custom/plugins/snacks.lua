return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    dashboard = { enabled = true },
    explorer = { enabled = true, follow_file = true, sort = { fields = { 'sort' } } },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true, timeout = 3000 },
    picker = { enabled = true, hidden = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
  },
  keys = {
    -- Core pickers
    { '<leader><space>', function() Snacks.picker.smart() end, desc = 'Smart Find Files' },
    { '<leader>,', function() Snacks.picker.buffers() end, desc = 'Buffers' },
    { '<leader>/', function() Snacks.picker.grep() end, desc = 'Grep' },
    { '<leader>:', function() Snacks.picker.command_history() end, desc = 'Command History' },
    { '<leader>n', function() Snacks.picker.notifications() end, desc = 'Notification History' },

    -- Explorer
    { '<leader>ef', function() Snacks.explorer.open() end, desc = 'File Explorer' },

    -- Find
    { '<leader>fb', function() Snacks.picker.buffers() end, desc = 'Buffers' },
    { '<leader>ff', function() Snacks.picker.files { hidden = true } end, desc = 'Find Files' },
    { '<leader>fg', function() Snacks.picker.git_files() end, desc = 'Find Git Files' },
    { '<leader>fr', function() Snacks.picker.recent() end, desc = 'Recent' },

    -- Git
    { '<leader>gb', function() Snacks.picker.git_branches() end, desc = 'Git Branches' },
    { '<leader>gl', function() Snacks.picker.git_log() end, desc = 'Git Log' },
    { '<leader>gs', function() Snacks.picker.git_status() end, desc = 'Git Status' },
    { '<leader>gg', function() Snacks.lazygit() end, desc = 'Lazygit' },

    -- Search
    { '<leader>sw', function() Snacks.picker.grep_word() end, desc = 'Grep word', mode = { 'n', 'x' } },
    { '<leader>sd', function() Snacks.picker.diagnostics() end, desc = 'Diagnostics' },
    { '<leader>sh', function() Snacks.picker.help() end, desc = 'Help Pages' },
    { '<leader>sk', function() Snacks.picker.keymaps() end, desc = 'Keymaps' },

    -- LSP
    { 'gd', function() Snacks.picker.lsp_definitions() end, desc = 'Goto Definition' },
    { 'gD', function() Snacks.picker.lsp_declarations() end, desc = 'Goto Declaration' },
    { 'gr', function() Snacks.picker.lsp_references() end, nowait = true, desc = 'References' },
    { 'gI', function() Snacks.picker.lsp_implementations() end, desc = 'Goto Implementation' },
    { 'gy', function() Snacks.picker.lsp_type_definitions() end, desc = 'Goto Type Definition' },
    { '<leader>ss', function() Snacks.picker.lsp_symbols() end, desc = 'LSP Symbols' },

    -- Other
    { '<leader>z', function() Snacks.zen() end, desc = 'Toggle Zen Mode' },
    { '<leader>.', function() Snacks.scratch() end, desc = 'Toggle Scratch Buffer' },
    { '<leader>bd', function() Snacks.bufdelete() end, desc = 'Delete Buffer' },
    { '<c-/>', function() Snacks.terminal() end, desc = 'Toggle Terminal' },
    { ']]', function() Snacks.words.jump(vim.v.count1) end, desc = 'Next Reference', mode = { 'n', 't' } },
    { '[[', function() Snacks.words.jump(-vim.v.count1) end, desc = 'Prev Reference', mode = { 'n', 't' } },
  },
  init = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      callback = function()
        _G.dd = function(...) Snacks.debug.inspect(...) end
        _G.bt = function() Snacks.debug.backtrace() end
        vim.print = _G.dd

        Snacks.toggle.option('spell', { name = 'Spelling' }):map '<leader>us'
        Snacks.toggle.option('wrap', { name = 'Wrap' }):map '<leader>uw'
        Snacks.toggle.diagnostics():map '<leader>ud'
        Snacks.toggle.line_number():map '<leader>ul'
        Snacks.toggle.treesitter():map '<leader>uT'
        Snacks.toggle.inlay_hints():map '<leader>uh'
        Snacks.toggle.indent():map '<leader>ug'
      end,
    })
  end,
}
