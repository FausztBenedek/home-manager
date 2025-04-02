return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    local intellijIconBackgroundOnHover = "#a7acb9"
    local intellijFileExplorerFilenameTextColor = "#1f2020"
    require("catppuccin").setup({
      flavour = "frappe", -- latte, frappe, macchiato, mocha
      transparent_background = true,
      highlight_overrides = {
        all = function(colors)
          -- Command to play around with it

          return {
            -- highlight StatusLine guifg=#FFFCF0 guibg=#6C8CD5
            StatusLine = { fg = "#FFFCF0", bg = "#6C8CD5" },
            -- highlight StatusLineNC guifg=#FFFCF0 guibg=#6A6761
            StatusLineNC = { fg = "#FFFCF0", bg = "#6A6761" },
            -- highlight DiffAdd    guibg=#4D6008
            DiffAdd = { bg = "#4D6008" },
            -- highlight DiffChange guibg=#2F4975
            DiffChange = { bg = "#2F4975" },
            -- highlight DiffDelete guibg=#5A1814
            DiffDelete = { bg = "#5A1814" },
            -- highlight DiffText guibg=#4A66A0
            DiffText = { bg = "#4A66A0" },
          }
        end,
      },
      color_overrides = {
        frappe = {
          rosewater = "#E5C6AA",
          flamingo = "#E08C82",
          pink = "#D35D8C",
          mauve = "#A02F6F",
          red = "#AF3029",
          maroon = "#87372B",
          peach = "#C46735",
          yellow = "#AD8301",
          green = "#66800B",
          teal = "#24837B",
          sky = "#3C7899",
          sapphire = "#205EA6",
          blue = "#6C8CD5", -- Filenames in nvim-tree
          lavender = "#CEC5E4",

          text = "#FFFCF0",
          subtext1 = "#E4E0D4",
          subtext0 = "#CBC6BA",
          overlay2 = "#B2ADA1",
          overlay1 = "#999489", -- Adjusted to match general visibility
          overlay0 = "#807C71",
          surface2 = "#6A6761",
          surface1 = "#54514D", -- Numbers at the start of the line
          surface0 = "#3E3B38",

          base = "#282726",
          mantle = "#1F1E1D", -- nvim-tree background, statusline at the bottom
          crust = "#161514",
        },
      },
    })
    require("catppuccin").load()
  end,
}
