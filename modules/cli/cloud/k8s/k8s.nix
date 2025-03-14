{ config, pkgs, lib, ... }:
{
  options = {
    option.cli.cloud.k8s.enable = lib.mkOption {
      type = lib.types.bool;
      description = "Enable tools for kubernetes";
      default = false;
    };
  };
  config = lib.mkIf config.option.cli.cloud.k8s.enable {
    home.shellAliases = {
      k = "kubecolor";
    };

    home.packages = with pkgs; [
      k9s
      kubectl
      kubecolor
      kubernetes-helm
      (
        pkgs.writeShellApplication {
          name = "k8s-context-switch";
          runtimeInputs = [ fzf yq-go ];
          text = ''
            if [ ! -f ~/.kube/config ]; then
              echo "No k8s config file found under ~/.kube/config"
              exit 1
            fi
            yq '.contexts[].name' ~/.kube/config |
            	fzf |
            	xargs kubectl config use-context
          '';
        }
      )
    ];
  };
}
