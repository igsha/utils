{ stdenv, lib, makeWrapper,
bashInteractive, httpie, jq, htmlq, ripgrep, which, gnused,
coreutils, python3Packages, parallel, fzf, xdg-utils
}:

stdenv.mkDerivation rec {
  pname = "utils";
  version = "0.1";

  buildInputs = [
    bashInteractive
    httpie
    jq
    fzf
    htmlq
    ripgrep
    which
    gnused
    coreutils
    python3Packages.yq
    parallel
    fzf
    xdg-utils
  ];

  nativeBuildInputs = [
    makeWrapper
  ];

  src = ./.;
  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src/src/*.sh $out/bin
    for __prog in $out/bin/*.sh; do
      wrapProgram "$__prog" --prefix PATH : '${lib.makeBinPath buildInputs}'
    done
  '';

  meta = with lib; {
    description = "Utility scripts";
    homepage = "https://github.com/igsha/utils";
    maintainers = [ maintainers.igsha ];
    platforms = platforms.linux;
    license = licenses.mit;
  };
}
