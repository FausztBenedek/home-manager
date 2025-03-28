return function(config)
  require("lspconfig").terraformls.setup({
    capabilities = config.capabilities,
  })
end
