local gh = require('util').gh

vim.pack.add { gh 'rebelot/kanagawa.nvim' }

require('kanagawa').setup {
  compile = false,
  undercurl = true,
  commentStyle = { italic = true },
  keywordStyle = { italic = true },
  statementStyle = { bold = true },
  transparent = false,
  dimInactive = false,
  terminalColors = true,
  theme = 'dragon',
  background = {
    dark = 'dragon',
    light = 'wave',
  },
}

vim.o.background = 'dark'
vim.cmd.colorscheme 'kanagawa'
