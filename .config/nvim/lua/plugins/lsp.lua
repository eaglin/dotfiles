-- LSP plugins and language server configuration.

local servers = {
  eslint = {},
  html = {},
  cssls = {},
  jsonls = {},
  stylua = {},

  lua_ls = {
    on_init = function(client)
      client.server_capabilities.documentFormattingProvider = false

      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
      end

      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
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
    end,
    settings = {
      Lua = {
        format = { enable = false },
      },
    },
  },
}

local plugins = {
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/mason-org/mason-lspconfig.nvim',
  'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
  'https://github.com/mfussenegger/nvim-jdtls',
}

vim.pack.add(plugins)

require('mason').setup {}

local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, { 'jdtls' })

require('mason-tool-installer').setup { ensure_installed = ensure_installed }

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
    map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/documentHighlight', event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
        end,
      })
    end

    if client and client:supports_method('textDocument/inlayHint', event.buf) then
      map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
    end
  end,
})

local angularls_config = {
  filetypes = { 'typescript', 'html', 'htmlangular' },
  root_markers = { 'angular.json', 'nx.json' },
  cmd = function(dispatchers, config)
    local root_dir = config.root_dir or vim.fs.dirname(vim.fs.find({ 'angular.json', 'nx.json' }, { upward = true })[1] or '') or vim.fn.getcwd()
    local node_modules = vim.fs.joinpath(root_dir, 'node_modules')
    local ngserver = node_modules and vim.fs.joinpath(node_modules, '.bin', 'ngserver')

    if not ngserver or vim.fn.executable(ngserver) ~= 1 then
      vim.notify('Angular LSP requires local @angular/language-server in this project', vim.log.levels.WARN)
      return
    end

    local angular_core_version = ''
    local package_json = vim.fs.joinpath(node_modules, '@angular', 'core', 'package.json')
    local ok, package_blob = pcall(vim.fn.readblob, package_json)
    if ok and package_blob then
      local package = vim.json.decode(package_blob) or {}
      angular_core_version = package.version or ''
    end

    return vim.lsp.rpc.start({
      ngserver,
      '--stdio',
      '--tsProbeLocations',
      node_modules,
      '--ngProbeLocations',
      node_modules,
      '--angularCoreVersion',
      angular_core_version,
    }, dispatchers)
  end,
}

vim.lsp.config('angularls', angularls_config)
vim.lsp.enable('angularls')

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'java',
  group = vim.api.nvim_create_augroup('jdtls-java', { clear = true }),
  callback = function()
    local root_dir = vim.fs.root(0, { 'mvnw', 'gradlew', 'pom.xml', 'build.gradle', 'build.gradle.kts', 'settings.gradle', 'settings.gradle.kts' })
      or vim.fs.root(0, { '.git' })
    if not root_dir then return end

    local jdtls = vim.fn.exepath 'jdtls'
    if jdtls == '' then
      vim.notify('jdtls is not installed yet. Open :Mason or restart Neovim after Mason installs it.', vim.log.levels.WARN)
      return
    end

    local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
    local workspace_dir = vim.fs.joinpath(vim.fn.stdpath 'data', 'jdtls-workspaces', project_name)
    local lombok = vim.fs.joinpath(vim.fn.stdpath 'data', 'mason', 'packages', 'jdtls', 'lombok.jar')
    local cmd = { jdtls, '-data', workspace_dir }
    if vim.uv.fs_stat(lombok) then
      vim.list_extend(cmd, {
        '--jvm-arg=-javaagent:' .. lombok,
      })
    else
      vim.notify('JDTLS Lombok jar not found: ' .. lombok, vim.log.levels.WARN)
    end

    local jdtls_client = require 'jdtls'

    jdtls_client.start_or_attach {
      name = 'jdtls',
      cmd = cmd,
      root_dir = root_dir,
      settings = {
        java = {},
      },
      init_options = {
        bundles = {},
      },
    }

    local opts = { buffer = true }
    local map = function(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, vim.tbl_extend('force', opts, { desc = 'Java: ' .. desc })) end
    local code_action = function(kind) return function() vim.lsp.buf.code_action { context = { only = { kind } } } end end

    map('n', '<leader>joi', jdtls_client.organize_imports, '[O]rganize [I]mports')
    map('n', '<leader>juc', jdtls_client.update_project_config, '[U]pdate Project [C]onfig')
    map('n', '<leader>jll', '<cmd>JdtShowLogs<CR>', 'Show JDTLS [L]ogs')
    map('n', '<leader>jwr', '<cmd>JdtWipeDataAndRestart<CR>', '[W]ipe workspace and [R]estart')

    map('n', '<leader>jev', jdtls_client.extract_variable, '[E]xtract [V]ariable')
    map('v', '<leader>jev', function() jdtls_client.extract_variable(true) end, '[E]xtract [V]ariable')
    map('n', '<leader>jec', jdtls_client.extract_constant, '[E]xtract [C]onstant')
    map('v', '<leader>jec', function() jdtls_client.extract_constant(true) end, '[E]xtract [C]onstant')
    map('v', '<leader>jem', function() jdtls_client.extract_method(true) end, '[E]xtract [M]ethod')

    map('n', '<leader>jgs', code_action 'source.generate.accessors', '[G]enerate Getter/Setter')
    map('n', '<leader>jgc', code_action 'source.generate.constructor', '[G]enerate [C]onstructor')
    map('n', '<leader>jgo', code_action 'source.overrideMethods', '[G]enerate [O]verrides')
    map('n', '<leader>jge', code_action 'source.generate.hashCodeEquals', '[G]enerate [E]quals/HashCode')
    map('n', '<leader>jgt', code_action 'source.generate.toString', '[G]enerate [T]oString')

    map('n', '<leader>jtc', jdtls_client.test_class, '[T]est [C]lass')
    map('n', '<leader>jtn', jdtls_client.test_nearest_method, '[T]est [N]earest Method')
  end,
})

for name, server in pairs(servers) do
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end
