local gh = require('util').gh

vim.pack.add {
  gh 'neovim/nvim-lspconfig',
  gh 'mason-org/mason.nvim',
  gh 'mason-org/mason-lspconfig.nvim',
  gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
  gh 'j-hui/fidget.nvim',
}

require('fidget').setup {}
require('mason').setup {}

require 'plugins.lsp.attach'

local servers = require 'plugins.lsp.servers'
local tools = {
  'stylua',
}

local ensure_installed = vim.tbl_keys(servers)
vim.list_extend(ensure_installed, tools)

require('mason-tool-installer').setup { ensure_installed = ensure_installed }

local capabilities = require('blink.cmp').get_lsp_capabilities()

for name, server in pairs(servers) do
  server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end
