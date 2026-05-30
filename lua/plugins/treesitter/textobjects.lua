require('nvim-treesitter-textobjects').setup {
  select = {
    lookahead = true,

    selection_modes = {
      ['@function.outer'] = 'V',
      ['@class.outer'] = 'V',
      ['@block.outer'] = 'V',
      ['@loop.outer'] = 'V',
      ['@conditional.outer'] = 'V',

      ['@parameter.outer'] = 'v',
      ['@parameter.inner'] = 'v',
      ['@call.outer'] = 'v',
      ['@call.inner'] = 'v',
    },

    set_jumps = true,
  },
}

local ts_select = require 'nvim-treesitter-textobjects.select'

local function select_textobject(lhs, capture, desc)
  vim.keymap.set({ 'x', 'o' }, lhs, function() ts_select.select_textobject(capture, 'textobjects') end, { desc = desc })
end

select_textobject('aF', '@function.outer', 'around function')
select_textobject('iF', '@function.inner', 'inside function')
select_textobject('ac', '@class.outer', 'around class/struct')
select_textobject('ic', '@class.inner', 'inside class/struct')
select_textobject('ag', '@parameter.outer', 'around argument/parameter')
select_textobject('ig', '@parameter.inner', 'inside argument/parameter')
select_textobject('ak', '@block.outer', 'around block')
select_textobject('ao', '@loop.outer', 'around loop')
select_textobject('io', '@loop.inner', 'inside loop')
select_textobject('ad', '@conditional.outer', 'around conditional')
select_textobject('id', '@conditional.inner', 'inside conditional')

local ts_move = require 'nvim-treesitter-textobjects.move'

vim.keymap.set({ 'n', 'x', 'o' }, ']f', function() ts_move.goto_next_start('@function.outer', 'textobjects') end, { desc = 'next function start' })

vim.keymap.set({ 'n', 'x', 'o' }, '[f', function() ts_move.goto_previous_start('@function.outer', 'textobjects') end, { desc = 'previous function start' })

vim.keymap.set({ 'n', 'x', 'o' }, ']F', function() ts_move.goto_next_end('@function.outer', 'textobjects') end, { desc = 'next function end' })

vim.keymap.set({ 'n', 'x', 'o' }, '[F', function() ts_move.goto_previous_end('@function.outer', 'textobjects') end, { desc = 'previous function end' })

vim.keymap.set({ 'n', 'x', 'o' }, ']C', function() ts_move.goto_next_start('@class.outer', 'textobjects') end, { desc = 'next class/struct start' })

vim.keymap.set({ 'n', 'x', 'o' }, '[C', function() ts_move.goto_previous_start('@class.outer', 'textobjects') end, { desc = 'previous class/struct start' })

local ts_swap = require 'nvim-treesitter-textobjects.swap'

vim.keymap.set('n', '<leader>xp', function() ts_swap.swap_next '@parameter.inner' end, { desc = 'swap parameter with next' })

vim.keymap.set('n', '<leader>xP', function() ts_swap.swap_previous '@parameter.inner' end, { desc = 'swap parameter with previous' })
