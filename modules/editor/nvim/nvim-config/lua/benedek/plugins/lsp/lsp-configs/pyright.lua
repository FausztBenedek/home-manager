return function(config)
  require("lspconfig").basedpyright.setup({
    capabilities = config.capabilities,
  })
end
