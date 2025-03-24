{ ... }: {
  home.username = "benedekfauszt";
  home.homeDirectory = "/Users/benedekfauszt";
  option.gui.enable = false;
  option.cli.cloud.aws.enable = false;
  option.cli.tools.safe-rm.enable = false;
  option.editor.jetbrains.enable = false;
  option.mac.aerospace.enable = false;
  option.mac.maccy.enable = false;
  option.dev.js.enable = false;
  option.dev.python.enable = false;
  option.dev.java.enable = false;
  git = {
    name = "FausztBenedek";
    email = "fausztb@gmail.com";
  };
  #additionalNvmCommands = [];
}
