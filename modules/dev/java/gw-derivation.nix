{ stdenv, lib, fetchFromGitHub, ... }:

with lib;

let
in
stdenv.mkDerivation rec {
  name = "gng";
  version = "v1.0.3";


  src = fetchFromGitHub {
    owner = "gdubw";
    repo = "gng";
    rev = "v1.0.3";
    sha256 = "sha256-QbyvCglSuQmSLBSSqVnRFqf9Tv1Bt4bUmfHrfR3Ci4A=";
  };
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r ./* $out
    runHook postInstall
  '';

}
