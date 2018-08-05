{ stdenv, lib, fetchFromGitHub, buildGoPackage }:

with lib;

buildGoPackage rec {
  name = "zsh-history";

  src = fetchFromGitHub {
    owner = "b4b4r07";
    repo = "zsh-history";
    rev = "507ccadcc140a62fce2dd8d179b669cbaae24b50";
    sha256 = "0d5w1rgb5ksfldrs54qf2pmy1rpqrayngfaa6xvfrrdhypr9grwz";
  };

  goDeps = ./deps.nix;
  goPackagePath = "zsh-history";

  preConfigure = ''
    # Extract the source
    mkdir -p "$NIX_BUILD_TOP/go/src/github.com/b4b4r07"
    cp -a $NIX_BUILD_TOP/source "$NIX_BUILD_TOP/go/src/github.com/b4b4r07/zsh-history"
    export GOPATH=$NIX_BUILD_TOP/go/src/github.com/b4b4r07/zsh-history:$GOPATH
  '';

  installPhase = ''
    mkdir -p "$bin/bin"
    install -m 0755 $NIX_BUILD_TOP/go/bin/zhist "$bin/bin"
  '';

  meta = {
    description = "A plugin for zsh history extended by golang, dealing it like SQL - Binary components";
    license = licenses.mit;
    homepage = https://github.com/b4b4r07/zsh-history;
    platforms = platforms.unix;
  };
}
