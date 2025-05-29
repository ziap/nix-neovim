{
  description = "Zap's custom Neovim config with Nix";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    custom-neovim = pkgs.callPackage ./neovim.nix {};
  in {
    packages.${system}.default = custom-neovim;
    apps.${system}.default = {
      type = "app";
      program = "${custom-neovim}/bin/nvim";
    };
    devShell.${system} = pkgs.mkShell {
      buildInputs = [ custom-neovim ];
    };
  };
}
