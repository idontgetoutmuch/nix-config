# nix-config

git clone https://github.com/idontgetoutmuch/nix-config.git

cd nix-config

nix-build -I nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/nixos-19.03.tar.gz

This will produce something like

/nix/store/cpg4g97fzrdf099fnia8ydq8vh3pm0rj-ihaskell-with-packages

Copy this and then

/nix/store/cpg4g97fzrdf099fnia8ydq8vh3pm0rj-ihaskell-with-packages/bin/ihaskell-notebook

This will launch a jupyter notebook environment

Open e.g. TestPackages.ipynb
