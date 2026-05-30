vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = false }),

  callback = function(event)
    local function map(keys, func, desc, mode)
      vim.keymap.set(mode or 'n', keys, func, {
        buffer = event.buf,
        desc = 'LSP: ' .. desc,
      })
    end

    map('grn', vim.lsp.buf.rename, 'Rename')
    map('gra', vim.lsp.buf.code_action, 'Code action', { 'n', 'x' })
    map('grD', vim.lsp.buf.declaration, 'Goto declaration')

    map('<leader>ch', '<cmd>LspClangdSwitchSourceHeader<CR>', 'Clangd switch source/header')

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then return end

    if client:supports_method('textDocument/documentHighlight', event.buf) then
      local group = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })

      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = group,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = group,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        buffer = event.buf,
        group = vim.api.nvim_create_augroup('lsp-detach', { clear = false }),

        callback = function(detach_event)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds {
            group = 'lsp-highlight',
            buffer = detach_event.buf,
          }
        end,
      })
    end

    if client:supports_method('textDocument/inlayHint', event.buf) then
      map(
        '<leader>th',
        function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled {
            bufnr = event.buf,
          })
        end,
        'Toggle inlay hints'
      )
    end
  end,
})
