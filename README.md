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

## Jupyter running R with required packages

Still in nix-config

nix-shell --pure -I nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/b6d906732c823b0e5f55b3a9309a9cc120c977aa.tar.gz shell.nix

This will launch a jupyter notebook with the required R packages.
