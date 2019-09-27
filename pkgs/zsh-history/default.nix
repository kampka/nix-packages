{ stdenv, lib, fetchFromGitHub, buildGoPackage }:

with lib;

buildGoPackage rec {
  name = "zsh-history";

  src = fetchFromGitHub {
    owner = "b4b4r07";
    repo = "history";
    rev = "527e6f51873992fbf9c1aad70aa3009a0027a8de";
    sha256 = "12dc380zfg3b9k7rcsyzi9dxqh28c4957b3fsx1nxvqvdm3ralm2";
  };

  goDeps = ./deps.nix;
  goPackagePath = "history";

  preConfigure = ''
    # Extract the source
    mkdir -p "$NIX_BUILD_TOP/go/src/github.com/b4b4r07"
    cp -a $NIX_BUILD_TOP/source "$NIX_BUILD_TOP/go/src/github.com/b4b4r07/history"
    export GOPATH=$NIX_BUILD_TOP/go/src/github.com/b4b4r07/history:$GOPATH
  '';

  installPhase = ''
    install -d "$bin/bin"
    install -m 0755 $NIX_BUILD_TOP/go/bin/history "$bin/bin"
    install -d $out/share
    cp -r $NIX_BUILD_TOP/go/src/history/misc/* $out/share
    cp -r $out/share/zsh/completions $out/share/zsh/site-functions
  '';

  meta = {
    description = "A CLI to provide enhanced history for your shell";
    license = licenses.mit;
    homepage = https://github.com/b4b4r07/history;
    platforms = platforms.unix;
    outputsToInstall = [ "out" "bin" ];
  };
}
