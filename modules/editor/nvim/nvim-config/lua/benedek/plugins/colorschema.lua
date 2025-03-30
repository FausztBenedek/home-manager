return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    local intellijIconBackgroundOnHover = "#a7acb9"
    local intellijFileExplorerFilenameTextColor = "#1f2020"
    require("catppuccin").setup({
      flavour = "latte", -- latte, frappe, macchiato, mocha
      transparent_background = true,
      color_overrides = {
        latte = {
          rosewater = "#E85A72",
          flamingo = "#E85A72",
          pink = "#B84C85",
          mauve = "#8B4D8B",
          red = "#B53E4D",
          maroon = "#9A4F4F",
          peach = "#C76E00",
          yellow = "#8B8000",
          green = "#4D7876",
          teal = "#4B878F",
          sky = "#6FA9CF",
          sapphire = "#0D469A",
          blue = "#4A64A8", -- Filenames in nvim-tree
          lavender = "#5E6CD5",
          text = "#3C3F57",
          subtext1 = "#4C5068",
          subtext0 = "#5A5E73",
          overlay2 = "#686C80",
          overlay1 = "#767A8D", -- Adjusted to match general visibility
          overlay0 = "#898EA0",
          surface2 = "#979CAF",
          surface1 = "#A5ABBC", -- Numbers at the start of the line
          surface0 = "#B6BCCB", -- Background for autocomplete, and telescope match highlight
          base = "#B6BCCB",
          mantle = "#C5CCDA", -- nvim-tree background, statusline at the bottom
          crust = "#B8BEC9",
        },
      },
    })
    require("catppuccin").load()
  end,
}
