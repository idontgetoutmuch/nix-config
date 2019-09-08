# nix-config

## Jupyter notebook running Haskell with inline-r with required Haskell and R packages

git clone https://github.com/idontgetoutmuch/nix-config.git

cd nix-config

nix-shell --pure -I nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/b6d906732c823b0e5f55b3a9309a9cc120c977aa.tar.gz withR.nix

This will produce something like

/nix/store/cpg4g97fzrdf099fnia8ydq8vh3pm0rj-ihaskell-with-packages

N.B. do not copy the line above but what your build produces and then

/nix/store/cpg4g97fzrdf099fnia8ydq8vh3pm0rj-ihaskell-with-packages/bin/ihaskell-notebook

This will launch a jupyter notebook environment

Open e.g. TestPackages.ipynb

If you want extra R packages, modify these two lines

<kbd>packages = with rsuper.rPackages; [ ggplot2 dplyr xts purrr cmaes cubature ];</kbd>

<kbd>buildInputs = with nixpkgs; [ R rPackages.ggplot2 rPackages.dplyr rPackages.xts rPackages.purrr rPackages.cmaes rPackages.cubature ];</kbd>

If you want extra Haskell packages, modify the following expression

<kbd>  packages = self: [
    self.inline-r
    self.hmatrix
    # we can re-introduce this when it gets fixed
    # self.hmatrix-sundials
    self.random-fu
    self.my-random-fu-multivariate
  ];
</kbd>

## Jupyter running R with required packages

Still in nix-config

nix-shell --pure -I nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/b6d906732c823b0e5f55b3a9309a9cc120c977aa.tar.gz shell.nix

This will launch a jupyter notebook with the required R packages.

If you want extra packages, modify this line

<kbd>my-R-packages = with rPackages; [ cmaes ggplot2 dplyr ];</kbd>

to include any required R packages.
