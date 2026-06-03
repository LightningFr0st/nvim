local ls = require 'luasnip'
local fmt = require('luasnip.extras.fmt').fmt
local rep = require('luasnip.extras').rep

local s = ls.snippet
local i = ls.insert_node

local templates = {
  read = 'const auto* {} = {}.get<{}>();',
  read_assert = 'const auto* {} = {}.get<{}>();\nPF_ASSERT({} != nullptr);',
  read_if_null = table.concat({
    'const auto* {} = {}.get<{}>();',
    'if ({} == nullptr)',
    '{{',
    '    {}',
    '}}',
  }, '\n'),

  write = 'auto* {} = {}.get_for_write<{}>();',
  write_assert = 'auto* {} = {}.get_for_write<{}>();\nPF_ASSERT({} != nullptr);',
  write_if_null = table.concat({
    'auto* {} = {}.get_for_write<{}>();',
    'if ({} == nullptr)',
    '{{',
    '    {}',
    '}}',
  }, '\n'),

  assert_only = 'PF_ASSERT({});',

  observable_group = table.concat({
    'const auto iterable = {}->iterable();',
    'auto components = iterable.components();',
    'for (auto it = components.begin(); it != components.end(); ++it)',
    '{{',
    '    auto* {} = static_cast<{}*>(*it);',
    '    if (it.is_field_changed({}->{}))',
    '    {{',
    '        ',
    '    }}',
    '}}',
  }, '\n'),
}

local function get_nodes()
  return {
    i(1, 'component'),
    i(2, 'entity'),
    i(3, 'Component'),
  }
end

local function get_assert_nodes()
  return {
    i(1, 'component'),
    i(2, 'entity'),
    i(3, 'Component'),
    rep(1),
  }
end

local function get_if_null_nodes()
  return {
    i(1, 'component'),
    i(2, 'entity'),
    i(3, 'Component'),
    rep(1),
    i(4, 'return;'),
  }
end

local function get_observable_group_nodes()
  return {
    i(1, 'group'),
    i(2, 'component'),
    i(3, 'Component'),
    rep(2),
    i(4, 'field'),
  }
end

return {
  s('gcomp', fmt(templates.read, get_nodes())),
  s('gcompa', fmt(templates.read_assert, get_assert_nodes())),
  s('gcompi', fmt(templates.read_if_null, get_if_null_nodes())),

  s('wcomp', fmt(templates.write, get_nodes())),
  s('wcompa', fmt(templates.write_assert, get_assert_nodes())),
  s('wcompi', fmt(templates.write_if_null, get_if_null_nodes())),

  s('pfa', fmt(templates.assert_only, { i(1, 'condition') })),

  s('ogroup', fmt(templates.observable_group, get_observable_group_nodes())),
}
