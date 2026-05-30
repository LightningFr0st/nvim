local gh = require('util').gh

vim.pack.add {
  { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' },
  gh 'nvim-treesitter/nvim-treesitter-textobjects',
}

local parsers = {
  'bash',
  'c',
  'cpp',
  'cmake',
  'diff',
  'html',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'query',
  'vim',
  'vimdoc',
  'yaml',
  'python',
}

require('nvim-treesitter').install(parsers)

local function attach_treesitter(buf, language)
  if not vim.treesitter.language.add(language) then return end

  vim.treesitter.start(buf, language)

  vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  vim.wo.foldmethod = 'expr'
  vim.o.foldlevel = 99
  vim.o.foldlevelstart = 99

  if vim.treesitter.query.get(language, 'indents') then vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
end

local available_parsers = require('nvim-treesitter').get_available()

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('treesitter-attach', { clear = true }),

  callback = function(args)
    local language = vim.treesitter.language.get_lang(args.match)
    if not language then return end

    local installed_parsers = require('nvim-treesitter').get_installed 'parsers'

    if vim.tbl_contains(installed_parsers, language) then
      attach_treesitter(args.buf, language)
    elseif vim.tbl_contains(available_parsers, language) then
      require('nvim-treesitter').install(language):await(function() attach_treesitter(args.buf, language) end)
    else
      attach_treesitter(args.buf, language)
    end
  end,
})

require 'plugins.treesitter.textobjects'
