return {
  -- {
  --   "rose-pine/neovim",
  --   name = "rose-pine",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require("rose-pine").setup({
  --       variant = "moon", -- opciones: 'auto', 'main', 'moon', 'dawn'
  --       dark_variant = "moon",
  --       dim_inactive_windows = true,
  --       extend_background_behind_borders = true,
  --       highlight_overrides = function()
  --         return {
  --           -- Personaliza los grupos de resaltado aquí
  --           -- Por ejemplo:
  --           -- Normal = { bg = "#1f1f28" },
  --           Cursor = { bg = "#F6C177", fg = "#1f1f28" },
  --           CursorLine = { bg = "#2a2a37", fg = "#cdd6f4" },
  --         }
  --       end,
  --       highlight_groups = {
  --         -- Ajustes opcionales de contraste
  --       },
  --     })
  --
  --     -- Establecer el tema como predeterminado
  --     vim.cmd("colorscheme rose-pine")
  --   end,
  -- },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- opciones: latte, frappe, macchiato, mocha
        background = {
          light = "latte",
          dark = "mocha",
        },
        transparent_background = false,
        show_end_of_buffer = false,
        term_colors = true,
        dim_inactive = {
          enabled = false,
          shade = "dark",
          percentage = 0.15,
        },
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
        },
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          notify = true,
          mini = {
            enabled = true,
            indentscope_color = "",
          },
        },
        custom_highlights = function(colors)
          return {
            Cursor = { fg = colors.green },
            CursorLine = { bg = colors.surface0 },
          }
        end,
      })

      -- Activar el tema
      vim.cmd("colorscheme catppuccin")
    end,
  },
}
