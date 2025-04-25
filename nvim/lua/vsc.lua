local keymap = vim.keymap.set

vim.opt.guicursor = ''

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv 'HOME' .. '/.vim/undodir'
vim.opt.undofile = true
vim.g.undotree_WindowLayout = 2
vim.g.undotree_SetFocusWhenToggle = 1

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = 'yes'
vim.opt.isfname:append '@-@'

vim.opt.updatetime = 50

vim.opt.colorcolumn = '80'

vim.g.mapleader = ' '

keymap('v', 'J', ":m '>+1<CR>gv=gv")
keymap('v', 'K', ":m '<-2<CR>gv=gv")

keymap('n', 'J', 'mzJ`z')
keymap('n', '<C-d>', '<C-d>zz')
keymap('n', '<C-u>', '<C-u>zz')
keymap('n', 'n', 'nzzzv')
keymap('n', 'N', 'Nzzzv')

-- greatest remap ever
keymap('x', '<leader>p', [["_dP]])

-- next greatest remap ever : asbjornHaland
keymap({ 'n', 'v' }, '<leader>y', [["+y]])
keymap('n', '<leader>Y', [["+Y]])

keymap({ 'n', 'v' }, '<leader>d', '"_d')

-- This is going to get me cancelled
keymap('i', '<C-c>', '<Esc>')

keymap('n', 'Q', '<nop>')

keymap('n', '<C-k>', '<cmd>cnext<CR>zz')
keymap('n', '<C-j>', '<cmd>cprev<CR>zz')
keymap('n', '<leader>k', '<cmd>lnext<CR>zz')
keymap('n', '<leader>j', '<cmd>lprev<CR>zz')

keymap({ 'n', 'v' }, '<leader>t', "<cmd>lua require('vscode').action('workbench.action.terminal.toggleTerminal')<CR>")
keymap({ 'n', 'v' }, '<leader>b', "<cmd>lua require('vscode').action('editor.debug.action.toggleBreakpoint')<CR>")
keymap({ 'n', 'v' }, '<leader>d', "<cmd>lua require('vscode').action('editor.action.showHover')<CR>")
keymap({ 'n', 'v' }, '<leader>a', "<cmd>lua require('vscode').action('editor.action.quickFix')<CR>")
keymap({ 'n', 'v' }, '<leader>sp', "<cmd>lua require('vscode').action('workbench.actions.view.problems')<CR>")
keymap({ 'n', 'v' }, '<leader>cn', "<cmd>lua require('vscode').action('notifications.clearAll')<CR>")
keymap({ 'n', 'v' }, '<leader>ff', "<cmd>lua require('vscode').action('workbench.action.quickOpen')<CR>")
keymap({ 'n', 'v' }, '<leader>cp', "<cmd>lua require('vscode').action('workbench.action.showCommands')<CR>")
keymap({ 'n', 'v' }, '<leader>pr', "<cmd>lua require('vscode').action('code-runner.run')<CR>")
keymap({ 'n', 'v' }, '<leader>fd', "<cmd>lua require('vscode').action('editor.action.formatDocument')<CR>")
keymap({ 'n', 'v' }, '<leader>gg', "<cmd>lua require('vscode').action('workbench.view.scm')<CR>")

-- project manager keymaps
keymap({ 'n', 'v' }, '<leader>pa', "<cmd>lua require('vscode').action('projectManager.saveProject')<CR>")
keymap({ 'n', 'v' }, '<leader>po', "<cmd>lua require('vscode').action('projectManager.listProjectsNewWindow')<CR>")
keymap({ 'n', 'v' }, '<leader>pe', "<cmd>lua require('vscode').action('projectManager.editProjects')<CR>")
