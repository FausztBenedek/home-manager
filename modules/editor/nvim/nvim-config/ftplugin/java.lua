-- jdtls configuration, see https://github.com/mfussenegger/nvim-jdtls
local jdtls_location = os.getenv("_NVIM_HELPER_LOCATION_OF_JAVA_JDTLS")

local home = os.getenv("HOME")
local workspace_path = home .. "/.local/share/nvim/jdtls-workspace/"
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = workspace_path .. project_name

local status, jdtls = pcall(require, "jdtls")
if not status then
  return
end
local extendedClientCapabilities = jdtls.extendedClientCapabilities

local config = {
  cmd = {
    "java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xmx1g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",
    "-javaagent:" .. os.getenv("_NVIM_HELPER_LOCATION_OF_LOMBOK"),
    "-jar",
    vim.fn.glob(jdtls_location .. "/share/java/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
    "-configuration",
    home .. "/.local/share/nvim/jdtls-workspace/config_mac", -- The config.ini that is included in that directory by default is symlinked to the nix store. I could not use the one from the nix store directly, because for some reason jdtls wants to write stuff (some kind of logfiles) into config_mac
    "-data",
    workspace_dir,
  },
  -- Root_dir originally contained { "build.gradle", "pom.xml" }, but it messed up navigation between subprojects
  root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "settings.gradle", "settings.gradle.kts" }),
  capabilities = require("blink.cmp").get_lsp_capabilities(),
  settings = {
    java = {
      signatureHelp = { enabled = true },
      extendedClientCapabilities = extendedClientCapabilities,
      maven = {
        downloadSources = true,
      },
      referencesCodeLens = {
        enabled = true,
      },
      references = {
        includeDecompiledSources = true,
      },
      inlayHints = {
        parameterNames = {
          enabled = "all", -- literals, all, none
        },
      },
      format = {
        enabled = false,
      },
    },
  },

  init_options = {
    bundles = {},
  },
}

require("jdtls").start_or_attach(config)
