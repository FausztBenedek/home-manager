```lua
["yamlls"] = function()
  -- Based on this article https://www.arthurkoziel.com/json-schemas-in-neovim/
  lspconfig["yamlls"].setup({
    capabilities = capabilities,
    filetypes = {
      "yml",
      "yaml",
    },
    settings = {
      validate = true,
      -- disable the schema store
      schemaStore = {
        enable = false,
        url = "",
      },
      -- manually select schemas
      schemas = {
        ["https://json.schemastore.org/kustomization.json"] = "kustomization.{yml,yaml}",
        ["https://raw.githubusercontent.com/docker/compose/master/compose/config/compose_spec.json"] = "docker-compose*.{yml,yaml}",
        ["https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/argoproj.io/application_v1alpha1.json"] = "argocd-application.yaml",
      },
    },
  })
end,

```
