local gh = require('util').gh

vim.pack.add { gh 'stevearc/overseer.nvim' }

local overseer = require 'overseer'

overseer.setup {
  disable_template_modules = {
    'overseer.template.npm',
  },
  component_aliases = {
    default = {
      'on_exit_set_status',
      'on_complete_notify',
    },
  },
}

overseer.register_template(require 'plugins.tasks.template.cmake_template')

vim.keymap.set('n', '<leader>or', '<cmd>OverseerRun<CR>', { desc = 'Overseer run task' })
vim.keymap.set('n', '<leader>oo', '<cmd>OverseerToggle<CR>', { desc = 'Overseer toggle' })
vim.keymap.set('n', '<leader>oa', '<cmd>OverseerTaskAction<CR>', { desc = 'Overseer task action' })
