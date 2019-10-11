# Introduction

These instructions use the nixpkgs hash that corresponds to 19.09
which should be released "real soon now" (TM).

# nix-config

## Jupyter notebook running Haskell with inline-r with required Haskell and R packages

```
git clone https://github.com/idontgetoutmuch/nix-config.git

cd nix-config

nix-shell --pure -I nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/e6b068cd952e4640d416c2ccd62587d8a35cd774.tar.gz withR.nix
```

This will produce something like

```
/nix/store/cpg4g97fzrdf099fnia8ydq8vh3pm0rj-ihaskell-with-packages
```

N.B. do not copy the line above but what your build produces and then

```
/nix/store/cpg4g97fzrdf099fnia8ydq8vh3pm0rj-ihaskell-with-packages/bin/ihaskell-notebook
```

This will launch a jupyter notebook environment

Open e.g. `TestPackages.ipynb`

If you want extra R packages, modify these two lines

`packages = with rsuper.rPackages; [ ggplot2 dplyr xts purrr cmaes cubature ];`

`buildInputs = with nixpkgs; [ R rPackages.ggplot2 rPackages.dplyr rPackages.xts rPackages.purrr rPackages.cmaes rPackages.cubature ];`

If you want extra Haskell packages, modify the following expression

```
packages = self: [
    self.inline-r
    self.hmatrix
    # we can re-introduce this when it gets fixed
    # self.hmatrix-sundials
    self.random-fu
    self.my-random-fu-multivariate
  ];
```

## Jupyter running R and Pythion with required packages

Still in nix-config

`
nix-shell --pure -I nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/e6b068cd952e4640d416c2ccd62587d8a35cd774.tar.gz shell.nix
`

This will launch a jupyter notebook with the required R packages and
the required Python packages.

If you want extra R packages, modify this line

`my-R-packages = with rPackages; [ cmaes ggplot2 dplyr ];`

to include any required R packages.

If you want extra Python packages, modify this line

`my-python-packages = [ python37Packages.numpy python37Packages.scikits-odes];`

to include any required Python packages.

## Python Shell with SUNDIALS (scikits-odes)

```
	nix-shell --pure -I nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/e6b068cd952e4640d416c2ccd62587d8a35cd774.tar.gz  -p python37Packages.scikits-odes --run "python3"
```

Strangely I didn't seem to have to mention `numpy` on the
above. If you need more packages then just add `-p packageName`.

Note that the hash of the nixpkgs database is different from the one
for the notebooks. Our PR to fix `scikits-odes` only got accepted yesterday [2019-09-08
Sun].

# Nix for Docker Images #

To build a a docker image from nix instructions, I have put an example [here](https://github.com/idontgetoutmuch/nixpkgs/blob/azure-bis/pkgs/build-support/docker/examples.nix#L108).

This builds a docker image in which you can run R with the specified
packages (`ggplot` and `dplyr` in this example).

The instructions(!) on how to actually build the image are [here](https://github.com/idontgetoutmuch/nixpkgs/blob/azure-bis/pkgs/build-support/docker/examples.nix#L3).

To make the image available (I think) I did

    docker login docker.io
    docker tag 7600adc93770 cinimod/foo-bar
    docker push cinimod/foo-bar

and then to use it

    docker login
    docker pull cinimod/foo-bar
    docker run -it cinimod/foo-bar:latest R

I started work on producing a docker image in which you could run
Jupyter notebooks but my [attempt](https://github.com/idontgetoutmuch/nixpkgs/blob/azure-bis/pkgs/build-support/docker/examples.nix#L121) did **not** work.

I imagine a bit of digging into notebooks and nix would enable someone to get this to work.

Of course, it's far from ideal that we would have to modifiy something in the nixpkgs repo to build
such docker images but I imagine this can all be made independent of
having to have all the source of nixpkgs itself.

# Nixos on Azure
## Introduction ##

These are some incomplete notes from my experiences in setting up
nixos on azure. I haven't gone back and checked I can re-create
another azure nixos VM.

### Acknowledgements ###

It wouldnn't have been possible to do this without the help of the
folks on #nixos especially @clever and @colemickens.

## On Ubuntu ##

I first had to create an ubuntu azure VM as I couldn't get the azure
cli to work on my macbook.

```
uname -a
Linux sundials 5.0.0-1018-azure #19~18.04.1-Ubuntu SMP Wed Aug 21 05:13:05 UTC 2019 x86<sub>64</sub> x86<sub>64</sub> x86<sub>64</sub> GNU/Linux
```

Also install nix and `nix-env -i tmux` unless you enjoy typing.

You can see the changes I had to make on top of @colemickens great set
of scripts [here](https://github.com/idontgetoutmuch/nixpkgs/tree/azure-bis).

1.  Remove `kvm` from `requiredSystemFeatures` in `nixos/lib/testing.nix`.
2.  Increase the diskSize in `azure-mkimage.nix` to something like 2048.
3.  Wherever the instructions say `az.sh` just use `az`.
4.  At some point in the proceedings you will have to
    1.  `az login`
5.  I also had to start an ssh agent `` eval `ssh-agent` `` and add a key
    to it `ssh-add ~/.ssh/id_rsa`.
6.  It's useful to install `pciutils` to check you actually do have a
    GPU `lspci | grep -i NVIDIA`.

### Create From Custom Image ###

I changed `location:-"westus2"` to `location:-"uksouth"` in
`create-image.sh` as I think azure objected to creating a machine in
the area different to the one in which I was located (I may be
mis-remembering). Azure didn't seem to object keeping the other US
locations.

    disk="$(./build-custom-vhd.sh)/disk.vhd"
    azimage="$(group=nixos-user-vhds ./create-image.sh "nixos-${RANDOM}" "${disk}")"
    azsigimage="$(group=nixos-user-vhds ./create-sig-image-version.sh "1.0.0" "${azimage}")"
    
    group="nixos-testvm-$RANDOM"
    az group create -n "${group}" -l "westus2"
    az vm create \
      --name "testVM" \
      --resource-group "${group}" \
      --os-disk-size-gb "100" \
      --image "${azsigimage}" \
      --admin-username "${USER}" \
      --location "WestCentralUS" \
      --ssh-key-values "$(ssh-add -L)"


## On Azure / Nixos ##

Create or modify `/etc/nixos/configuration.nix`.

    { modulesPath, ... }:
    
    {
      # To build the configuration or use nix-env, you need to run
      # either nixos-rebuild --upgrade or nix-channel --update
      # to fetch the nixos channel.
    
      # This configures everything but bootstrap services,
      # which only need to be run once and have already finished
      # if you are able to see this comment.
      imports = [ "${modulesPath}/virtualisation/azure-common.nix" ];
      hardware.opengl.enable = true;
      services.xserver.videoDrivers = [ "nvidia" ];
      nixpkgs.config.allowUnfree = true;
    }

`sudo -i nixos-rebuild boot; sudo reboot`

`ls /run/opengl-driver/lib` should have files in it as should `ls -l /dev/nvidia*`.

If anything goes wrong, try stopping and starting the VM via the Azure
Portal.

    with import <nixpkgs> { config.allowUnfree = true; };
    
    stdenv.mkDerivation {
     name = "myCUDA";
     buildInputs = [ (python37.withPackages (pkgs: [pkgs.tensorflowWithCuda])) ];
     LD_LIBRARY_PATH="${linuxPackages.nvidia_x11}/lib";
    }

## Notes ##

Of course these may be ephemeral but I am going to leave them here anyway.

1.  <https://github.com/colemickens/nixpkgs/blob/azure/nixos/maintainers/scripts/azure/release-images.nix#L5-L10>
2.  <https://gist.github.com/cleverca22/f6ee9044aa4528c3bb52a0b195e9d938>
3.  <https://logs.nix.samueldr.com/nixos/2019-09-22>
4.  <https://github.com/tensorflow/tensorflow/issues/32623>


# TODO

 1. Put hashes in a `.nix` file so they don't have to be typed on the command line.
 2. Single nix derivation that allows R, Haskell and Python kernels.

