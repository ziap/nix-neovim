-- For ease of adding servers
local servers = {
  'pyright',
  'clangd',
  'html',
  'cssls',
  'denols',
  'ts_ls',
  'emmet_ls',
  'rust_analyzer',
  'nushell',
  'svelte',
  'gopls',
  'vue_ls',
}

vim.lsp.config('pyright', {
  cmd = function(dispatchers)
    local uv_project = vim.fs.root(0, { 'uv.lock', 'pyproject.toml' })
    local command = uv_project
      and { 'uv', 'run', 'pyright-langserver', '--stdio' }
      or { 'pyright-langserver', '--stdio' }
    return vim.lsp.rpc.start(command, dispatchers)
  end,
})

vim.lsp.config('denols', {
  root_markers = {"deno.json", "deno.jsonc"},
})

local vue_plugin =  (function()
  local bin = vim.fn.exepath('vue-language-server')

  if bin == '' then
    return nil
  end

  local root = vim.fs.dirname(vim.fs.dirname(bin))
  local candidates = {
    root .. '/lib/language-tools/packages/language-server', -- Nix
    root .. '/lib/node_modules/@vue/language-server',       -- npm
  }

  for _, location in ipairs(candidates) do
    if vim.uv.fs_stat(location) then
      return {
        name = '@vue/typescript-plugin',
        location = location,
        languages = { 'vue' },
        configNamespace = 'typescript',
      }
    end
  end

  return nil
end)()

vim.lsp.config('ts_ls', {
  root_markers = { 'package.json' },
  single_file_support = false,
  filetypes = (function ()
    local filetypes = {
      'javascript',
      'javascriptreact',
      'typescript',
      'typescriptreact',
    }

    if vue_plugin then
      filetypes[#filetypes + 1] = 'vue'
    end

    return filetypes
  end)(),

  init_options = (function()
    if vue_plugin then
      return { plugins = { vue_plugin } }
    end

    return {}
  end)(),
})

for _, name in ipairs(servers) do
  vim.lsp.enable(name)
end
