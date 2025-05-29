-- For ease of adding servers
local servers = {
  'pyright',
  'clangd',
  'html',
  'cssls',
  'ts_ls',
  'emmet_ls',
  'rust_analyzer',
  'nushell',
  'svelte',
}

for _, name in ipairs(servers) do
  vim.lsp.enable(name)
end
