local function exists(file)
  local ok, err, code = os.rename(file, file)
  if not ok then
    if code == 13 then -- Permission denied, but it exists
      return true
    end
  end
  return ok, err
end
local function isdir(path)
  -- "/" works on both Unix and Windows
  return exists(path .. "/")
end

return function(config)
  local node_version = "v20.11.0"
  local vue_path = os.getenv("NODE_DEPENDENCIES_INSTALLED_BY_NIX") .. "/lib/node_modules/@vue/"
  local vue_typescriptpath = vue_path .. "/typescript-plugin"
  local vue_language_server_path = vue_path .. "/language-server"
  require("lspconfig").ts_ls.setup({
    capabilities = config.capabilities,
    init_options = {
      preferences = {
        includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all'
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
      plugins = {
        {
          name = "@vue/typescript-plugin",
          -- Change this to the location the plugin is installed to
          location = vue_typescriptpath,
          languages = { "javascript", "typescript", "typescriptreact", "vue", "tsx" },
        },
        {
          name = "@vue/typescript-plugin",
          location = vue_language_server_path,
          languages = { "vue" },
        },
      },
    },
    filetypes = {
      "javascript",
      "typescript",
      "typescriptreact",
      "vue",
      "tsx",
    },
  })
end
