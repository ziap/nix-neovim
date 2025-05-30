{
  description = "Zap's custom Neovim config with Nix";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    neovimPackage = system: let
      pkgs = import nixpkgs {inherit system;};
    in 
      pkgs.callPackage ./neovim.nix {};
  in {
    packages = forAllSystems (system: {
      default = neovimPackage system;
    });
    apps = forAllSystems (system: {
      default = {
        type = "app";
        program = "${neovimPackage system}/bin/nvim";
      };
    });
  };
}
