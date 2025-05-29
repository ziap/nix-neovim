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

in symlinkJoin {
  name = "neovim-custom";
  paths = [ pkgs.neovim-unwrapped ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/nvim \
      --add-flags '-u' \
      --add-flags '${init-lua}' \
      --set-default NVIM_APPNAME nvim-custom \
      --set PATH ${lib.makeBinPath extraPackages}
  '';

  passthru = {
    inherit packpath;
  };
}
