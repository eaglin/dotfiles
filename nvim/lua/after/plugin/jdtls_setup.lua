local M = {}

function M:setup()
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
  local workspace_dir = vim.fn.stdpath("data")
    .. package.config:sub(1, 1)
    .. "jdtls-workspace"
    .. package.config:sub(1, 1)
    .. project_name

  -- See `:help vim.lsp.start` for an overview of the supported `config` options.
  local config = {
    name = "jdtls",

    -- `cmd` defines the executable to launch eclipse.jdt.ls.
    -- `jdtls` must be available in $PATH and you must have Python3.9 for this to work.
    --
    -- As alternative you could also avoid the `jdtls` wrapper and launch
    -- eclipse.jdt.ls via the `java` executable
    -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
    cmd = {
      "jdtls",
      "-data",
      workspace_dir,
    },

    -- `root_dir` must point to the root of your project.
    -- See `:help vim.fs.root`
    root_dir = vim.fs.root(0, { "gradlew", ".git", "mvnw" }),

    -- Here you can configure eclipse.jdt.ls specific settings
    -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
    -- for a list of options
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

    -- This sets the `initializationOptions` sent to the language server
    -- If you plan on using additional eclipse.jdt.ls plugins like java-debug
    -- you'll need to set the `bundles`
    --
    -- See https://codeberg.org/mfussenegger/nvim-jdtls#java-debug-installation
    --
    -- If you don't plan on any eclipse.jdt.ls plugins you can remove this
    init_options = {
      bundles = {},
    },
  }
  require("jdtls").start_or_attach(config)
end
