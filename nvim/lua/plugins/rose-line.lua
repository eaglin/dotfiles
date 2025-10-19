return {
  "maxmx03/roseline",
  opts = {},
  dependencies = {
    "rose-pine/neovim",
  },
  config = function()
    require("roseline").setup({
      theme = "rose-pine",
      layout = {
        a = section_a,
        b = section_b,
        c = section_c,
        d = section_d,
        e = section_e,
      },
      icons = {
        vim = "",
        git = {
          head = "",
          added = "",
          changed = "",
          removed = "",
        },
        diagnostic = {
          Error = "",
          Warning = "",
          Information = "",
          Question = "",
          Hint = "󰌶",
          Debug = "",
          Ok = "󰧱",
        },
        os = {
          Linux = "",
          microsoft = "",
          Darwin = "",
        },
        default = { left = "", right = "" },
        block = { left = "█", right = "█" },
        round = { left = "", right = "" },
      },
    })
  end,
}
