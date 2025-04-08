
return function(config)
  require("lspconfig").astro.setup({
    capabilities = config.capabilities,
  })
end
