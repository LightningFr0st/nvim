local function run_build(name, cmd, cwd)
  local result = vim.system(cmd, { cwd = cwd }):wait()

  if result.code == 0 then return end

  local stderr = result.stderr or ''
  local stdout = result.stdout or ''
  local output = stderr ~= '' and stderr or stdout

  if output == '' then output = 'No output from build command.' end

  vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
end

local pack_handlers = {
  ['telescope-fzf-native.nvim'] = function(ev)
    if vim.fn.executable 'make' == 1 then run_build(ev.data.spec.name, { 'make' }, ev.data.path) end
  end,

  LuaSnip = function(ev)
    if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then run_build(ev.data.spec.name, { 'make', 'install_jsregexp' }, ev.data.path) end
  end,

  ['nvim-treesitter'] = function(ev)
    if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
    vim.cmd 'TSUpdate'
  end,
}

vim.api.nvim_create_autocmd('PackChanged', {
  group = vim.api.nvim_create_augroup('pack-changed', { clear = true }),

  callback = function(ev)
    if ev.data.kind ~= 'install' and ev.data.kind ~= 'update' then return end

    local handler = pack_handlers[ev.data.spec.name]
    if handler then handler(ev) end
  end,
})
