<div align="center">

# Nix Neovim

A small, portable Neovim config that only relies on nixpkgs and distributed as
a flake.

</div>

The configuration are stored entirely in `/nix/store`, making it more
self-contained and avoid polluting the home directory. Plugins and external
dependencies are managed with the flake itself.

## Quick start

If you have Nix and Nix flake installed, you can run the configured neovim with:

```sh
nix run
```

## Installation

TBA

# License

This project is licensed under the [GPL-3.0 license](LICENSE).
