return function(config)
  require("lspconfig").eslint.setup({
    capabilities = config.capabilities,
  })
end
