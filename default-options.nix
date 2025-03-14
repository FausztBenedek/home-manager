{ ... }: {
  home.username = "benedekfauszt";
  home.homeDirectory = "/Users/benedekfauszt";
  option.gui.enable = false;
  option.cli.cloud.aws.enable = false;
  option.cli.tools.safe-rm.enable = false;
  option.editor.jetbrains.enable = false;
  option.mac.aerospace.enable = true;
  option.mac.maccy.enable = true;
  git = {
    name = "FausztBenedek";
    email = "fausztb@gmail.com";
  };
  #additionalNvmCommands = [];
}
