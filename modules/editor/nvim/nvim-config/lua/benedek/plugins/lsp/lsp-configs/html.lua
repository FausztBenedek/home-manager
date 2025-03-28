return function(config)
  require("lspconfig").html.setup({
    capabilities = config.capabilities,
  })
end
