-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

-- Iterate over all Lua files in this directory and load them in a stable order.
local plugins_dir = vim.fs.joinpath(vim.fn.stdpath 'config', 'lua', 'plugins')
local modules = {}

for file_name, file_type in vim.fs.dir(plugins_dir) do
  if file_type == 'file' and file_name:match '%.lua$' and file_name ~= 'init.lua' then
    local module = file_name:gsub('%.lua$', '')
    table.insert(modules, module)
  end
end

local load_order = {
  luasnip = 10,
  ['blink-cmp'] = 20,
}

local disabled = {
  telescope = true,
  neotree = true
}

table.sort(modules, function(a, b)
  local order_a = load_order[a] or 100
  local order_b = load_order[b] or 100

  if order_a == order_b then return a < b end

  return order_a < order_b
end)

for _, module in ipairs(modules) do
  if not disabled[module] then require('plugins.' .. module) end
end
