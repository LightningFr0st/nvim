local gh = require('util').gh

vim.pack.add {
  {
    src = gh 'L3MON4D3/LuaSnip',
    version = vim.version.range '2.*',
  },
  {
    src = gh 'saghen/blink.cmp',
    version = vim.version.range '1.*',
  },
}

require('luasnip').setup {}

require('luasnip.loaders.from_lua').lazy_load {
  paths = vim.fn.stdpath 'config' .. '/lua/plugins/completion/snippets',
}

require('blink.cmp').setup {
  keymap = {
    preset = 'default',

    ['<C-l>'] = {
      function(cmp)
        return cmp.show {
          providers = { 'lsp' },
          force = true,
        }
      end,
      'show_documentation',
      'hide_documentation',
    },
  },

  appearance = {
    nerd_font_variant = 'mono',
  },

  completion = {
    keyword = {
      range = 'full',
    },

    documentation = {
      auto_show = false,
    },

    trigger = {
      show_in_snippet = true,
      show_on_trigger_character = true,
    },
  },

  sources = {
    default = { 'lsp', 'path', 'snippets' },
  },

  snippets = {
    preset = 'luasnip',
  },

  fuzzy = {
    implementation = 'lua',
  },

  signature = {
    enabled = true,
  },
}
