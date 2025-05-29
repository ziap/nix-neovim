-- Theme
vim.cmd.colorscheme 'gruvbox'
vim.opt.background = 'dark'

-- Search
vim.opt.showmatch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Status
vim.opt.laststatus = 2

-- Wrap
vim.opt.wrap = false

-- Indentation
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true

-- Integration
vim.opt.mouse = 'nv'
vim.opt.ttyfast = true

-- Sync clipboard lazily
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Layout
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.showmode = false

-- Disable backup
vim.opt.backup = false
vim.opt.writebackup = false

-- Split panes
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Add icons to vim diagnostic
local icons = {
  [vim.diagnostic.severity.ERROR] = '󰅚',
  [vim.diagnostic.severity.WARN] = '',
  [vim.diagnostic.severity.INFO] = '󰋽',
  [vim.diagnostic.severity.HINT] = '󰌶',
}

vim.diagnostic.config {
  virtual_text = {
    prefix = '',
    format = function(diagnostic)
      local icon = icons[diagnostic.severity] or '■'
      return string.format('%s %s', icon, diagnostic.message)
    end,
  },
  signs = {
    text = icons,
  },
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
    focusable = false,
    style = 'minimal',
    source = 'always',
    header = '',
    prefix = '',
  },
}

-- Disable ftplugin indentation rule
vim.cmd.filetype('plugin', 'indent', 'off')

-- Disable providers
vim.g.loaded_node_provider = false
vim.g.loaded_perl_provider = false
vim.g.loaded_python_provider = false
vim.g.loaded_python3_provider = false
vim.g.loaded_ruby_provider = false
