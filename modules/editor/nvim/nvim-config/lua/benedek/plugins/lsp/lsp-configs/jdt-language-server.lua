return function(config)
  require("lspconfig").jdtls.setup({
    capabilities = config.capabilities,
  })
end
