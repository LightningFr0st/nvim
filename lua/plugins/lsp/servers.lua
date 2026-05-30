---@type table<string, vim.lsp.Config>
return {
  clangd = {
    cmd = {
      'clangd',
      '--clang-tidy',
      '--log=verbose',
      '--background-index',
      '--header-insertion=never',
      '--query-driver=C:/Program Files/Microsoft Visual Studio/18/Community/VC/Tools/MSVC/*/bin/Hostx64/x64/cl.exe',
    },
  },

  ts_ls = {},

  lua_ls = {
    on_init = function(client)
      client.server_capabilities.documentFormattingProvider = false

      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        local has_luarc = vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')

        if path ~= vim.fn.stdpath 'config' and has_luarc then return end
      end

      local settings = client.config.settings or {}
      local lua_settings = settings.Lua or {}

      ---@cast settings table
      ---@cast lua_settings table

      settings.Lua = vim.tbl_deep_extend('force', lua_settings, {
        runtime = {
          version = 'LuaJIT',
          path = { 'lua/?.lua', 'lua/?/init.lua' },
        },
        workspace = {
          checkThirdParty = false,
          library = vim.tbl_extend('force', vim.api.nvim_get_runtime_file('', true), {
            '${3rd}/luv/library',
            '${3rd}/busted/library',
          }),
        },
      })

      client.config.settings = settings
    end,

    settings = {
      Lua = {
        format = {
          enable = false,
        },
      },
    },
  },
}
