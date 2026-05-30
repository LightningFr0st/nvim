local function make_configure_template(preset, display_name, cwd)
  return {
    name = 'CMake Configure Fresh Preset: ' .. display_name,

    builder = function()
      return {
        cmd = 'cmake',
        args = { '--preset', preset, '--fresh' },
        cwd = cwd,
        components = { 'default' },
      }
    end,
  }
end

local function make_build_target_template(preset, display_name, cwd)
  return {
    name = 'CMake Build Target: ' .. display_name,

    params = {
      target = {
        type = 'string',
        name = 'Target',
        desc = 'CMake target name. Multiple targets may be separated by spaces.',
      },
    },

    builder = function(params)
      local args = { '--build', '--preset', preset, '--target' }

      for target in params.target:gmatch '%S+' do
        table.insert(args, target)
      end

      return {
        cmd = 'cmake',
        args = args,
        cwd = cwd,
        components = { 'default' },
      }
    end,
  }
end

local function find_presets_dir(dir, file)
  if not dir or dir == '' then return nil end

  local preset_file = vim.fs.find(file, {
    upward = true,
    type = 'file',
    path = dir,
    limit = 1,
  })[1]

  return preset_file and vim.fs.dirname(preset_file) or nil
end

local function get_presets_dir(dir)
  dir = dir or vim.fn.getcwd()

  return find_presets_dir(dir, 'CMakeUserPresets.json')
    or find_presets_dir(dir, 'CMakePresets.json')
    or find_presets_dir(vim.fn.getcwd(), 'CMakeUserPresets.json')
    or find_presets_dir(vim.fn.getcwd(), 'CMakePresets.json')
end

local function parse_preset_line(line)
  local name, display_name = line:match '^%s*"([^"]+)"%s+-%s+(.+)%s*$'
  if name then return name, display_name end

  name = line:match '^%s*"([^"]+)"%s*$'
  if name then return name, name end
end

local function get_presets(dir)
  local templates = {}

  local configure_result = vim.system({ 'cmake', '-S', dir, '--list-presets=configure' }, { text = true }):wait()
  for line in configure_result.stdout:gmatch '[^\r\n]+' do
    local name, display_name = parse_preset_line(line)
    if name then table.insert(templates, make_configure_template(name, display_name, dir)) end
  end

  local build_result = vim.system({ 'cmake', '-S', dir, '--list-presets=build' }, { text = true }):wait()
  for line in build_result.stdout:gmatch '[^\r\n]+' do
    local name, display_name = parse_preset_line(line)
    if name then table.insert(templates, make_build_target_template(name, display_name, dir)) end
  end

  return templates
end

return {
  name = 'cmake presets',

  generator = function(search)
    local presets_dir = get_presets_dir(search.dir)
    if not presets_dir then return {} end

    return get_presets(presets_dir)
  end,
}
