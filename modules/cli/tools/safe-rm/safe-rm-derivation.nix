{ stdenv, fetchFromGitHub, ... }:

let
in
stdenv.mkDerivation {
  name = "shell-safe-rm";
  version = "1.0.7";


  src = fetchFromGitHub {
    owner = "kaelzhang";
    repo = "shell-safe-rm";
    rev = "1.0.7";
    sha256 = "sha256-+e9l6yRw6fDJsZoAmSV8/6Dv5W0rWkxDBWg43+/PS5w=";
  };

  # Skip build phase
  buildPhase = '' 
    echo "Skipping build phase"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp -r ./bin/rm.sh $out/bin/safe-rm
    chmod 755 $out/bin/safe-rm
    runHook postInstall
  '';
}
