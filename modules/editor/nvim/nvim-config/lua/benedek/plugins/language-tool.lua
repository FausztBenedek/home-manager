local function directory_exists(path)
  local stat = vim.loop.fs_stat(path)
  return stat and stat.type == 'directory'
end
return {
  "dpelle/vim-LanguageTool",
  config = function()
    -- The plugin is incompatible with newer versions of languagetool. This downloads the older archived version:
    -- See issue https://github.com/dpelle/vim-LanguageTool/issues/33
    local Job = require("plenary.job")
    local url = "https://languagetool.org/download/archive/LanguageTool-5.2.zip"
    local language_tool_directory = vim.fn.expand('~') .. "/.local/share/nvim/language-tool-old"
    local zipfile = language_tool_directory .. "/LanguageTool-5.2.zip"
    vim.g.languagetool_jar = language_tool_directory .. "/LanguageTool-5.2/languagetool-commandline.jar"

    if directory_exists(language_tool_directory) then
      return
    end
    -- Download the file
    print("Start downloading LanguageTool")
    Job:new({
      command = "wget",
      args = { "-P", language_tool_directory, url },
      on_stdout = function(_, data)
        print(data)
      end,
      on_exit = function(j, return_val)
        print("LanguageTool downloaded")
        if return_val ~= 0 then
          print("Error unzipping file: " .. table.concat(j:stderr_result(), "\n"))
          return
        end
        Job:new({
          command = "unzip",
          args = { "-o", zipfile, "-d", language_tool_directory },
          on_exit = function(j, return_val)
            if return_val ~= 0 then
              print("Error unzipping file: " .. table.concat(j:stderr_result(), "\n"))
              return
            end
            print("LanguageTool downloaded and unzipped successfully!")
          end,
        }):start()
      end,
    }):start()
  end,
}
