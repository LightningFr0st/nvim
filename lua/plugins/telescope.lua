local gh = require('util').gh

local plugins = {
  gh 'nvim-lua/plenary.nvim',
  gh 'nvim-telescope/telescope.nvim',
  gh 'nvim-telescope/telescope-ui-select.nvim',
  gh 'nvim-telescope/telescope-live-grep-args.nvim',
}

if vim.fn.executable 'make' == 1 then table.insert(plugins, gh 'nvim-telescope/telescope-fzf-native.nvim') end

vim.pack.add(plugins)

local telescope = require 'telescope'
local builtin = require 'telescope.builtin'
local themes = require 'telescope.themes'

telescope.setup {
  extensions = {
    ['ui-select'] = { themes.get_dropdown() },
  },
}

pcall(telescope.load_extension, 'fzf')
pcall(telescope.load_extension, 'ui-select')
pcall(telescope.load_extension, 'live_grep_args')

vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = 'Search help' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = 'Search keymaps' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = 'Search files' })
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = 'Search Telescope pickers' })
vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = 'Search current word' })
vim.keymap.set('n', '<leader>sg', function() telescope.extensions.live_grep_args.live_grep_args() end, { desc = 'Search by grep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = 'Search diagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = 'Search resume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = 'Search recent files' })
vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = 'Search commands' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = 'Search buffers' })

vim.keymap.set(
  'n',
  '<leader>/',
  function()
    builtin.current_buffer_fuzzy_find(themes.get_dropdown {
      winblend = 10,
      previewer = false,
      layout_config = {
        width = 0.8,
        height = 0.6,
      },
    })
  end,
  { desc = 'Search current buffer' }
)

vim.keymap.set(
  'n',
  '<leader>s/',
  function()
    builtin.live_grep {
      grep_open_files = true,
      prompt_title = 'Live grep in open files',
    }
  end,
  { desc = 'Search in open files' }
)

vim.keymap.set('n', '<leader>sn', function()
  builtin.find_files {
    cwd = vim.fn.stdpath 'config',
  }
end, { desc = 'Search Neovim config files' })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),

  callback = function(event)
    local buf = event.buf

    vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = 'Goto references' })
    vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = 'Goto implementation' })
    vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = 'Goto definition' })
    vim.keymap.set('n', 'gro', builtin.lsp_document_symbols, { buffer = buf, desc = 'Document symbols' })
    vim.keymap.set('n', 'grw', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Workspace symbols' })
    vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = 'Goto type definition' })
  end,
})
