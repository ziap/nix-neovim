{
  description = "Zap's custom Neovim config with Nix";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    nixpkgs.lib.mergeAttrsList 
      (map
        (system: let
          pkgs = import nixpkgs {inherit system;};
          custom-neovim = pkgs.callPackage ./neovim.nix {};
        in {
          packages.${system}.default = custom-neovim;
          apps.${system}.default = {
            type = "app";
            program = "${custom-neovim}/bin/nvim";
          };
          devShell.${system} = pkgs.mkShell {
            buildInputs = [custom-neovim];
          };
        })
        (builtins.attrNames nixpkgs.legacyPackages)
      );
}
