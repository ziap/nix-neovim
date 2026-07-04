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
