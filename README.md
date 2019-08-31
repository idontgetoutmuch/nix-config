# nix-config

git clone https://github.com/idontgetoutmuch/nix-config.git

nix-build -I nixpkgs=~/nixpkgs withR.nix

This will produce something like

/nix/store/cpg4g97fzrdf099fnia8ydq8vh3pm0rj-ihaskell-with-packages

Copy this and then

/nix/store/cpg4g97fzrdf099fnia8ydq8vh3pm0rj-ihaskell-with-packages/bin/ihaskell-notebook

This will launch a jupyter notebook environment

Open e.g. TestPackages.ipynb
