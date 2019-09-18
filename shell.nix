with import <nixpkgs> {};
let
# Change these if you need extra R or Python packages.

my-R-packages = with rPackages; [ cmaes ggplot2 dplyr xts ];
my-python-packages = [ python37Packages.numpy python37Packages.scikits-odes];

R-with-my-packages = rWrapper.override{ packages = with rPackages; my-R-packages ++ [ JuniperKernel ]; };
jupyter-R-kernel = stdenv.mkDerivation {
  name = "jupyter-R-kernel";
  buildInputs = [ python37Packages.jupyter python37Packages.notebook R-with-my-packages which ];
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
  buildInputs = [ jupyter-R-kernel python37Packages.jupyter ] ++ my-python-packages;
  shellHook = ''
    export JUPYTER_PATH=${jupyter-R-kernel}/share/jupyter
    # see https://github.com/NixOS/nixpkgs/issues/38733
    ${R-with-my-packages}/bin/R --slave -e "system2('jupyter', 'notebook')"
  '';
}
