with import <nixpkgs> {};
let
my-R-packages = with rPackages; [ cmaes ggplot2 dplyr ];
R-with-my-packages = rWrapper.override{ packages = with rPackages; my-R-packages ++ [ JuniperKernel ]; };
jupyter-R-kernel = stdenv.mkDerivation {
  name = "jupyter-R-kernel";
  buildInputs = [ pythonPackages.jupyter pythonPackages.notebook R-with-my-packages which ];
  unpackPhase = ":";
  installPhase = ''
    export HOME=$TMP
    echo $JUPYTER_PATH
    ${R-with-my-packages}/bin/R --slave -e "JuniperKernel::listKernels()"
    ${R-with-my-packages}/bin/R --slave -e "JuniperKernel::installJuniper(prefix='$out')"
  '';
};
in
mkShell rec {
  name = "jupyter-with-R-kernel";
  buildInputs = [ jupyter-R-kernel pythonPackages.jupyter ];
  shellHook = ''
    export JUPYTER_PATH=${jupyter-R-kernel}/share/jupyter
    # see https://github.com/NixOS/nixpkgs/issues/38733
    ${R-with-my-packages}/bin/R --slave -e "system2('jupyter', 'notebook')"
  '';
}
