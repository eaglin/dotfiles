vim.pack.add({
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/mason-org/mason.nvim' },
  { src = 'https://github.com/mason-org/mason-lspconfig.nvim' },
  { src = 'https://github.com/j-hui/fidget.nvim' },
})

require('fidget').setup({})

require('mason').setup({
  ui = { border = 'rounded' },
})

require('mason-lspconfig').setup({
  ensure_installed = {
    'ts_ls',
    'angularls',
  },
  -- Servers are configured and enabled explicitly below. Leaving Mason's
  -- automatic enablement on would start a second angularls client.
  automatic_enable = false,
})

local capabilities = require('blink.cmp').get_lsp_capabilities()

vim.lsp.config('ts_ls', {
  capabilities = capabilities,
})

-- nvim-lspconfig's Angular command probes project dependencies before its
-- Mason installation. Prefer the project's ngserver as well when it exists,
-- so workspaces on different Angular majors use their matching server.
local default_angular_cmd = vim.lsp.config.angularls.cmd

local function angular_core_version(root_dir)
  local package_json = vim.fs.joinpath(root_dir, 'node_modules', '@angular', 'core', 'package.json')
  local ok, contents = pcall(vim.fn.readblob, package_json)
  if not ok or not contents then return '' end

  local decoded_ok, package = pcall(vim.json.decode, contents)
  if not decoded_ok or type(package) ~= 'table' then return '' end

  return package.version or ''
end

local function angular_cmd(dispatchers, config)
  local root_dir = config.root_dir or vim.fn.getcwd()
  local node_modules = vim.fs.joinpath(root_dir, 'node_modules')
  local local_ngserver = vim.fs.joinpath(node_modules, '.bin', 'ngserver')

  if vim.fn.executable(local_ngserver) ~= 1 then return default_angular_cmd(dispatchers, config) end

  local ng_probe_locations = table.concat({
    vim.fs.joinpath(node_modules, '@angular', 'language-server', 'node_modules'),
    node_modules,
  }, ',')

  return vim.lsp.rpc.start({
    local_ngserver,
    '--stdio',
    '--tsProbeLocations',
    node_modules,
    '--ngProbeLocations',
    ng_probe_locations,
    '--angularCoreVersion',
    angular_core_version(root_dir),
  }, dispatchers)
end

vim.lsp.config('angularls', {
  capabilities = capabilities,
  cmd = angular_cmd,
  settings = {
    angular = {
      server = {
        useClientSideFileWatcher = true,
      },
      suggest = {
        autoImports = true,
        includeCompletionsWithSnippetText = true,
      },
    },
  },
})

vim.lsp.enable({ 'ts_ls', 'angularls' })
