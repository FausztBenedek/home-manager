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
          rosewater = "#dc8a78",
          flamingo = "#dd7878",
          pink = "#ea76cb",
          mauve = "#8839ef",
          red = "#d20f39",
          maroon = "#e64553",
          peach = "#fe640b",
          yellow = "#df8e1d",
          green = "#40a02b",
          teal = "#179299",
          sky = "#04a5e5",
          sapphire = "#209fb5",
          blue = "#1e66f5", -- Filenames in nvim-tree
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
