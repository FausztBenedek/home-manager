return function(config)
  require("lspconfig").bashls.setup({
    capabilities = config.capabilities,
  })
end
