local gh = require('util').gh

vim.pack.add { gh 'stevearc/overseer.nvim' }

require('overseer').setup {
  template_dirs = {
    'plugins.tasks.template',
  },
}

vim.keymap.set('n', '<leader>or', '<cmd>OverseerRun<CR>', { desc = 'Overseer run task' })
vim.keymap.set('n', '<leader>oo', '<cmd>OverseerToggle<CR>', { desc = 'Overseer toggle' })
vim.keymap.set('n', '<leader>oa', '<cmd>OverseerTaskAction<CR>', { desc = 'Overseer task action' })
