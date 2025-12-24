return {
  {
    "neovim/nvim-lspconfig",

    opts = {
      servers = {
        -- angularls = {
        --   -- Configuration for Angular Language Server
        --   root_dir = function(fname)
        --     return require("lspconfig.util").root_pattern("angular.json", "project.json")(fname)
        --   end,
        -- },
        nil_ls = {
          -- Configuration for nil (Nix Language Server), already installed via nix
          cmd = { "nil" },
          autostart = true,
          mason = false, -- Explicitly disable mason management for nil_ls
          settings = {
            ["nil"] = {
              formatting = { command = { "nixpkgs-fmt" } },
            },
          },
        },
      },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },
  -- {
  --   "mason-org/mason-lspconfig.nvim",
  --   opts = {
  --     automatic_enable = {
  --       exclude = {
  --         --needs external plugin
  --         "jdtls",
  --       },
  --     },
  --   },
  -- },
  -- { "mfussenegger/nvim-jdtls" },
}
