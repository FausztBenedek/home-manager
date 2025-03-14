return {
  {
    "norcalli/nvim-colorizer.lua", -- highlights color codes in their color
    config = function()
      require("colorizer").setup()
    end,
  },
}
