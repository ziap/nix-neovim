<div align="center">

# Nix Neovim

A small, portable Neovim config that only relies on nixpkgs and distributed as
a flake.

</div>

## Features

The editor is packaged as a pure nix flake distribution which bundles the
configuration, plugins, external tools and stores them `/nix/store`.

It also has a [wrapper](wrapper.c) that sets up `PATH`, wires the
configuration, and overrides `NVIM_APPNAME` to provide complete isolation from
`$HOME`. This allows you to have multiple neovim builds without conflict.

The plugin set is minimal, lightweight, preferring built-in features over
plugins. Plugins are for things that Neovim lacks a native equivalent for:

```nix
[
  # Dependency plugins
  vimPlugins.plenary-nvim
  vimPlugins.nvim-web-devicons

  # Fuzzy finder
  vimPlugins.telescope-nvim
  vimPlugins.telescope-fzf-native-nvim

  # Treesitter
  vimPlugins.nvim-treesitter.withAllGrammars

  # Completion
  vimPlugins.blink-cmp

  # LSP
  vimPlugins.nvim-lspconfig

  # Theming
  vimPlugins.gruvbox-nvim
  vimPlugins.lualine-nvim
]
```

Now that neovim has native [LSP
completion](https://neovim.io/doc/user/lsp/#lsp-completion), I might try and
remove `blink-cmp`.

## Quick start

If you have Nix and Nix flake installed, you can run the configured neovim with:

```sh
nix run github:ziap/nix-neovim
```

## Installation

### Option 1: Nix Profile, works without NixOS

```sh
nix profile install github:ziap/nix-neovim
```

To update later/uninstall

```sh
nix profile upgrade github:ziap/nix-neovim   # update
nix profile remove  github:ziap/nix-neovim   # uninstall
```

### Option 2: NixOS system package

You need to [set up your system configuration as a
flake](https://wiki.nixos.org/wiki/NixOS_system_configuration#Defining_NixOS_as_a_flake),
then add this flake as an input:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nix-neovim = {
      url = "github:ziap/nix-neovim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-neovim }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit nix-neovim; };   # makes nix-neovim visible in modules
      modules = [
        ./configuration.nix
      ];
    };
  };
}
```

Then in configuration.nix (or any imported module):

```nix
{ pkgs, nix-neovim, ... }:

let 
  system = pkgs.stdenv.hostPlatform.system;
in {
  environment.systemPackages = [
    nix-neovim.packages.${system}.default
  ];
}
```

Rebuild the system configuration as usual:

```sh
sudo nixos-rebuild switch --flake .
```

**Note:** Maybe I should add a `nixpkgs` overlay to make installation easier.

# License

This project is licensed under the [GPL-3.0 license](LICENSE).
