local dap = require 'dap'

local function first_glob(pattern)
  local matches = vim.fn.glob(pattern, false, true)
  return matches[1]
end

local function require_existing_file(path, label)
  if not path or path == '' then error(label .. ' was not found') end

  if not vim.uv.fs_stat(path) then error(label .. ' does not exist: ' .. path) end

  return vim.fs.normalize(path)
end

local vsdbg_path =
  require_existing_file(first_glob(vim.env.USERPROFILE .. [[\.vscode\extensions\ms-vscode.cpptools-*\debugAdapters\vsdbg\bin\vsdbg.exe]]), 'vsdbg.exe')

local vsda_node = require_existing_file(
  first_glob(vim.env.LOCALAPPDATA .. [[\Programs\Microsoft VS Code\*\resources\app\node_modules.asar.unpacked\vsda\build\Release\vsda.node]]),
  'vsda.node'
)
local sign_script = require_existing_file(vim.fs.joinpath(vim.fn.stdpath 'config', 'lua', 'plugins', 'debug', 'vsdbg-sign.js'), 'vsdbg-sign.js')

local function sign_handshake(value)
  local result = vim
    .system({
      'node',
      sign_script,
      value,
    }, {
      text = true,
      env = vim.tbl_extend('force', vim.fn.environ(), {
        VSDA_NODE = vsda_node,
      }),
    })
    :wait()

  if result.code ~= 0 then return nil, result.stderr ~= '' and result.stderr or result.stdout end

  return (result.stdout or ''):gsub('%s+$', '')
end

local function run_handshake(session, request)
  local value = request.arguments and request.arguments.value

  if not value then
    session:response(request, {
      success = false,
      message = 'vsdbg handshake request did not contain arguments.value',
    })
    return
  end

  local signature, err = sign_handshake(value)

  if not signature then
    session:response(request, {
      success = false,
      message = 'Failed to sign vsdbg handshake: ' .. tostring(err),
    })
    return
  end

  session:response(request, {
    success = true,
    body = {
      signature = signature,
    },
  })
end

dap.adapters.cppvsdbg = {
  id = 'cppvsdbg',
  type = 'executable',
  command = vsdbg_path,
  args = { '--interpreter=vscode' },
  options = {
    detached = false,
  },
  reverse_request_handlers = {
    handshake = run_handshake,
  },
}

dap.configurations.cpp = {
  {
    name = 'Attach to process (cppvsdbg)',
    type = 'cppvsdbg',
    request = 'attach',

    program = function() return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '\\', 'file') end,

    processId = require('dap.utils').pick_process,
    cwd = vim.fn.getcwd(),

    clientID = 'vscode',
    clientName = 'Visual Studio Code',

    externalConsole = false,
    requireExactSource = false,

    logging = {
      engineLogging = true,
      trace = true,
      traceResponse = true,
      moduleLoad = false,
    },
  },

  {
    name = 'Launch process (cppvsdbg)',
    type = 'cppvsdbg',
    request = 'launch',

    program = function() return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '\\', 'file') end,

    args = function()
      local args = vim.fn.input 'Arguments: '
      return args ~= '' and vim.split(args, ' ') or {}
    end,

    cwd = vim.fn.getcwd(),

    stopAtEntry = false,
    externalConsole = true,
    requireExactSource = false,

    clientID = 'vscode',
    clientName = 'Visual Studio Code',

    logging = {
      engineLogging = false,
      trace = false,
      traceResponse = false,
      moduleLoad = false,
    },
  },
}

dap.configurations.c = dap.configurations.cpp
