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

return function()
  local node_version = "v20.11.0"
  local vue_path = os.getenv("NVM_DIR") .. "/versions/node/" .. node_version .. "/lib/node_modules/@vue"
  local vue_typescriptpath = vue_path .. "/typescript-plugin"
  local vue_language_server_path = vue_path .. "/language-server"
  if not isdir(vue_typescriptpath) or not isdir(vue_language_server_path) then
    print(
      "ERROR Vue LSP will not work, check if you installed @vue/typescript-plugin and @vue/language-server globally with node " .. node_version
    )
  end
  require("lspconfig").ts_ls.setup({
    init_options = {
      plugins = {
        {
          name = "@vue/typescript-plugin",
          -- Change this to the location the plugin is installed to
          location = vue_typescriptpath,
          languages = { "javascript", "typescript", "vue", "tsx" },
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
      "vue",
      "tsx",
    },
  })
end
