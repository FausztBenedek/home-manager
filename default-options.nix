{ ... }: {
  home.username = "benedekfauszt";
  home.homeDirectory = "/Users/benedekfauszt";
  option.gui.enable = false;
  option.cli.cloud.aws.enable = false;
  option.cli.tools.safe-rm.enable = false;
  option.editor.jetbrains.enable = false;
  option.mac.enable = false;
  option.dev.js.enable = false;
  option.dev.python.enable = false;
  option.dev.java.enable = false;
  option.dev.rust.enable = false;
  git = {
    name = "FausztBenedek";
    email = "fausztb@gmail.com";
  };
  #additionalNvmCommands = [];
}
