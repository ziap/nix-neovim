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

for _, name in ipairs(servers) do
  vim.lsp.enable(name)
end

vim.lsp.config('denols', {
  root_markers = {"deno.json", "deno.jsonc"},
})

vim.lsp.config('ts_ls', {
  root_markers = {"package.json"},
  single_file_support = false,
})
