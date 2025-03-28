return function(config)
  require("lspconfig").pyright.setup({
    capabilities = config.capabilities,
  })
end
