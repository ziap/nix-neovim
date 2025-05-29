{
  pkgs,
  symlinkJoin,
  makeWrapper,
  writeText,
  runCommandLocal,
  vimPlugins,
  lib,
}: let
  foldPlugins = builtins.foldl' (
    acc: next:
      acc
      ++ [ next ]
      ++ (foldPlugins (next.dependencies or []))
  ) [];

  plugins = lib.unique (foldPlugins [
    vimPlugins.plenary-nvim
    vimPlugins.nvim-web-devicons
    vimPlugins.telescope-nvim
    vimPlugins.telescope-fzf-native-nvim
    vimPlugins.nvim-treesitter.withAllGrammars
    vimPlugins.lualine-nvim
    vimPlugins.blink-cmp
    vimPlugins.nvim-lspconfig
    vimPlugins.gruvbox-nvim
  ]);

  packageName = "myplugins";
  packpath = runCommandLocal "packpath" {} ''
    mkdir -p $out/pack/${packageName}/{start,opt}

    ${
      lib.concatMapStringsSep
        "\n"
        (plugin: "ln -s ${plugin} $out/pack/${packageName}/start/${lib.getName plugin}")
        plugins
    }
  '';

  init-lua = writeText "init.lua" /* lua */ ''
    local packpath = "${packpath}"
    vim.opt.packpath:append(packpath)
    vim.opt.runtimepath:append(packpath)

    ${builtins.readFile ./lua/plugins/telescope.lua}
    ${builtins.readFile ./lua/plugins/lualine.lua}
    ${builtins.readFile ./lua/plugins/treesitter.lua}
    ${builtins.readFile ./lua/plugins/lsp.lua}
    ${builtins.readFile ./lua/plugins/cmp.lua}

    ${builtins.readFile ./lua/options.lua}
    ${builtins.readFile ./lua/keymap.lua}
    ${builtins.readFile ./lua/autocmd.lua}
  '';

  extraPackages = [
    pkgs.git
    pkgs.xclip
    pkgs.wl-clipboard

    # Dependencies for telescope
    pkgs.ripgrep
    pkgs.fd

    # LSPs for languages that doesn't need complex version management
    pkgs.vscode-langservers-extracted
    pkgs.nodePackages.typescript-language-server
    pkgs.emmet-ls
    pkgs.clang-tools
  ];

  neovim-custom = pkgs.stdenv.mkDerivation {
    pname = "neovim-custom";
    version = "1.0.0";
    src = pkgs.writeText "wrapper.c" (builtins.replaceStrings
      [
        "<extra_paths>"
        "<command>"
        "<config_file>"
      ]
      [
        (lib.makeBinPath extraPackages)
        "${pkgs.neovim-unwrapped}/bin/nvim"
        "${init-lua}"
      ]
      (builtins.readFile ./wrapper.c));
    dontUnpack = true;
    buildPhase = ''
      cc -o nvim -O2 -s $src
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp nvim $out/bin/
    '';
  };

in symlinkJoin {
  name = "neovim-custom";
  paths = [ neovim-custom pkgs.neovim-unwrapped ];

  passthru = {
    inherit packpath;
  };
}
