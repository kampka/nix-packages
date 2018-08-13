{ stdenv, lib, fetchFromGitHub, buildGoPackage }:

with lib;

buildGoPackage rec {
  name = "zsh-history";

  src = fetchFromGitHub {
    owner = "b4b4r07";
    repo = "history";
    rev = "d0ddf53ca710cdc72eb1d10178937be74fc4a00e";
    sha256 = "0hymxkvb1v75af7k0i55cj0jfq41rlhs2nq438dd7fsyqf28dwgn";
  };

  goDeps = ./deps.nix;
  goPackagePath = "history";

  patches = [
    ./0001-Substiture-HOME-in-paths.patch
    ./0002-Create-paths-if-the-don-t-exist.patch
  ];

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
