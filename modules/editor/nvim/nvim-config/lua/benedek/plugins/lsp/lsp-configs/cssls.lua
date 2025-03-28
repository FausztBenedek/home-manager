return function(config)
  require("lspconfig").cssls.setup({
    capabilities = config.capabilities,
  })
end
