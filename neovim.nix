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
    src = pkgs.writeText "wrapper.c" /* c */ ''
      #include <stdio.h>
      #include <stdlib.h>
      #include <string.h>
      #include <unistd.h>

      int main(int argc, char **argv) {
        const char extra_paths[] = "${lib.makeBinPath extraPackages}";
        const char command[] = "${pkgs.neovim-unwrapped}/bin/nvim";

        char option[] = "-u";
        char config_file[] = "${init-lua}";

        const char *path = getenv("PATH");
        if (path == NULL) path = "";

        size_t path_len = strlen(path);
        size_t buf_size = path_len + sizeof(extra_paths) + 1;
        size_t args_size = sizeof(char*) * (argc + 3);
        if (args_size > buf_size) buf_size = args_size;

        void *buf = malloc(buf_size);
        if (buf == NULL) {
          perror("Failed to allocate memory");
          return 1;
        }

        char *updated = buf;
        memcpy(updated, path, path_len);
        updated[path_len] = ':';
        memcpy(updated + path_len + 1, extra_paths, sizeof(extra_paths));

        if (setenv("PATH", updated, 1) != 0) {
          perror("Failed to set virtual environment");
          free(updated);
          return 1;
        }

        char **args = buf;
        memcpy(args, argv, sizeof(char*) * argc);
        args[argc + 0] = option;
        args[argc + 1] = config_file;
        args[argc + 2] = NULL;

        execv(command, args);
        perror("Failed to execute command");
        free(buf);
        return 1;
      }
    '';
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
