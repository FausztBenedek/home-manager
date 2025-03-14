{ stdenv, lib, pkgs, nvmCommands }:

with lib;

let
in
stdenv.mkDerivation {
  name = "nvm";
  version = "v.0.39.7";


  src = fetchTarball {
    url = "https://github.com/nvm-sh/nvm/archive/refs/tags/v0.39.7.tar.gz";
    sha256 = "sha256-wtLDyLTF3eOae2htEjfFtx/54Vudsvdq65Zp/IsYTX8=";
  };

  buildPhase = ''
    rm ./install.sh
    echo "Skipping build phase"
  '';

  installPhase = ''
    runHook preInstall
    export NVM_DIR=$out/.nvm # By default or convention .nvm is in ~/.nvm, but then it would be impure. Instead all npm global packages are installed into the nix store from this declarative configuration.
    export HOME=$(pwd) # Without this nix wants to write error messages to /homeless-shelter directory, and does not allow to install stuff with `npm install -g ...`.
    export NVM_NODEJS_ORG_MIRROR=http://nodejs.org/dist # Without this nvm does not find any node versions
    chmod a+x nvm.sh
    mkdir -p $out/.nvm
    cp -r ./* $out
    source $out/nvm.sh
    chmod -R a+w $out/.nvm
    ${builtins.concatStringsSep "\n" nvmCommands}
    runHook postInstall
  '';
  buildInputs = [ pkgs.curl ];

}
