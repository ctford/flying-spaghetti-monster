{ doCheck ? true
, doClean ? true
}:

with import <nixpkgs> { };
with stdenv.lib;

let

  libName = "flying-spaghetti-monster";

  example = stdenv.mkDerivation {
    name = "${libName}-example";
    src = ./.;
    buildInputs = [ gmp libffi gcc haskellPackages.idris ];
    configurePhase = optional doClean ''
      idris --clean example/example.ipkg
      find . -name '*.ibc' -delete
    '';
    buildPhase = ''
      idris --build example/example.ipkg
    '';
    inherit doCheck;
    checkPhase = ''
      ./runexample | diff example/expected.txt -
    '';
    installPhase = ''
      install -m755 runexample $out
    '';
  };

  readme = stdenv.mkDerivation {
    name = "${example.name}-README.md";
    src = ./example;
    buildInputs = [ haskellPackages.pandoc ];
    installPhase = ''
      pandoc -f markdown_github+lhs \
             -t markdown_github \
             -s Example.lidr \
        | sed 's/ sourceCode/idris/' >$out
    '';
  };

  lib = stdenv.mkDerivation {
    name = "${libName}";
    src = ./.;
    buildInputs = [ haskellPackages.idris ];
    configurePhase = optional doClean ''
      idris --clean fsm.ipkg
      find . -name '*.ibc' -delete
    '';
    buildPhase = ''
      idris --build fsm.ipkg
    '';
    installPhase = ''
      install -m744 -d $out
      install -m444 -t $out src/*.ibc
      pushd src
      for subdir in $(find * -type d); do
        install -m744 -d $out/$subdir
        for ibc in $subdir/*.ibc; do
          install -m444 $ibc $out/$subdir
        done
      done
      popd
    '';
  };

  env = stdenv.mkDerivation {
    name = "${libName}-env";
    buildInputs = example.buildInputs ++ readme.buildInputs;
  };

in

if inNixShell then env else { inherit example readme lib env; }
