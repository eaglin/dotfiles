return {
  "mfussenegger/nvim-jdtls",
  ft = "java",
  config = function()
    local jdtls = require("jdtls")

    local root_dir_func = function(fname)
      local util = require("lspconfig.util")

      -- Buscar hacia arriba hasta encontrar un pom.xml con <modules>
      local root = util.root_pattern("pom.xml")(fname)
      if root then
        local pom_path = root .. "/pom.xml"
        if vim.fn.filereadable(pom_path) == 1 then
          local pom_content = table.concat(vim.fn.readfile(pom_path), "\n")
          if pom_content:match("<modules>") then
            return root
          end
        end
      end

      -- Si no encuentra pom padre, usar el directorio actual
      return vim.fn.getcwd()
    end

    local config = {
      cmd = { vim.fn.exepath("jdtls") },
      root_dir = root_dir_func(vim.api.nvim_buf_get_name(0)),
      settings = {
        java = {
          configuration = {
            maven = {
              globalSettings = "/home/mvabal/.sdkman/candidates/maven/3.6.1/conf/settings.xml",
              userSettings = "/home/mvabal/.sdkman/candidates/maven/3.6.1/conf/settings.xml",
              localRepository = "/home/mvabal/mavenrepo/",
              downloadSources = true,
              downloadJavadoc = true,
            },
            runtimes = {
              {
                name = "JavaSE-1.8",
                path = "/home/mvabal/.sdkman/candidates/java/8.0.462-amzn/",
                default = true,
              },
              {
                name = "JavaSE-21",
                path = "/home/mvabal/.sdkman/candidates/java/21.0.8.fx-zulu/",
              },
            },
            updateBuildConfiguration = "automatic",
          },
          autobuild = { enabled = true },
        },
      },
    }

    jdtls.start_or_attach(config)
  end,
}
