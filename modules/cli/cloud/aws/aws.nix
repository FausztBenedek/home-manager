{ config, pkgs, lib, ... }:
{
  options = {
    option.cli.cloud.aws.enable = lib.mkOption {
      type = lib.types.bool;
      description = "Enable tools for aws";
      default = false;
    };
  };
  config = lib.mkIf config.option.cli.cloud.aws.enable {

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "terraform"
      "claude-code"
    ];
    home.packages = with pkgs; [
      terraform
      terragrunt
      nodePackages.aws-cdk
      awscli2
      (pkgs.writeShellScriptBin "awsprofile-to-be-sourced" ''
        # Read the AWS config file and extract profile names
        # This was in the docs, but I just got an error message always, maybe because this script is run by bash version in nix.
        # export LC_ALL=en_US.utf8
        #
        if [ -n "$1" ]; then
          selected="$1"
        else 
          profiles=$(grep -oE '\[profile [^]]+\]' ~/.aws/config | sed 's/\[profile \(.*\)\]/\1/')

          # Check if profiles were found
          if [ -z "$profiles" ]; then
              echo "No profiles found in ~/.aws/config"
              exit 1
          fi

          # Use fzf to select an entry
          selected=$(printf "%s\n" "''${profiles[@]}" | fzf)
        fi
        export AWS_PROFILE=$selected
        echo "AWS_PROFILE set to $selected"
        print -s "awsprofile $selected"
      '')
    ];
    home.file.".zshrc.d/aws.zsh" = {
      text = ''
        # Because an environment variable has to be set, we have to source the script
        awsprofile() {
           source awsprofile-to-be-sourced $1
        }
      '';
    };
    # Faccher's trick to download stuff from aws
    # TODO: Build into aws.nix somehow
    # function awstunnel(){
    #   aws ssm start-session \
    #     --target i-034ff23bd6119c669 \
    #     --document-name AWS-StartPortForwardingSession \
    #     --parameters '{"portNumber":["22"], "localPortNumber":["2222"]}'
    # }
    #  
    # scp -P 2222 benedek.fauszt@localhost:/tmp/jenkins.tar.gz .
  };
}
