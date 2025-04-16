return function(config)
  require("lspconfig").tailwindcss.setup({
    capabilities = config.capabilities,
  })
end
