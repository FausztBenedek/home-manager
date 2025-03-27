return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    local intellijFileExplorerBackground = "#f6f7f9"
    local intellijIconBackgroundOnHover = "#a7acb9"
    local intellijFileExplorerFilenameTextColor = "#1f2020"
    require("catppuccin").setup({
      flavour = "latte", -- latte, frappe, macchiato, mocha
      color_overrides = {
        latte = {
          rosewater = "#F4C2C2",
          flamingo = "#FC6C85",
          pink = "#CE5D97",
          mauve = "#9F5F9F",
          red = "#D14D41",
          maroon = "#B56565",
          peach = "#F7A072",
          yellow = "#D0A215",
          green = "#879A39",
          teal = "#008080",
          sky = "#87CEEB",
          sapphire = "#0F52BA",
          blue = "#4385BE", -- Filenames in nvim-tree
          lavender = "#7287fd",
          text = "#4c4f69",
          subtext1 = "#5c5f77",
          subtext0 = "#6c6f85",
          overlay2 = "#7c7f93",
          overlay1 = intellijFileExplorerFilenameTextColor,
          overlay0 = "#9ca0b0",
          surface2 = "#acb0be",
          surface1 = intellijIconBackgroundOnHover, -- Numbers at the start of the line
          surface0 = "#ccd0da", -- Background for autocomplete, and telescope match highlight
          base = "#ffffff",
          mantle = intellijFileExplorerBackground, -- nvim-tree background, statusline at the bottom
          crust = "#dce0e8",
        },
      },
    })
    require("catppuccin").load()
  end,
}
