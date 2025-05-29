-- Helper function 
local function bind(mode)
  return function(lhs, rhs, silent)
    local options = {
      noremap = true,
      silent = silent or false,
    }
    vim.keymap.set(mode, lhs, rhs, options)
  end
end

local nmap = bind'n' -- nnoremap
local imap = bind'i' -- inoremap
local vmap = bind'v' -- vnoremap
local tmap = bind't' -- tnoremap

-- Set leader key
vim.g.mapleader = ' '

-- LSP keybinds
nmap('<leader>n', vim.diagnostic.goto_next, true)
nmap('<leader>N', vim.diagnostic.goto_prev, true)
nmap('<leader>k', vim.lsp.buf.hover)
nmap('<leader>r', vim.lsp.buf.rename)
nmap('<leader>ca', vim.lsp.buf.code_action)

nmap('gd', vim.lsp.buf.definition)
nmap('gi', vim.lsp.buf.implementation)
nmap('gr', vim.lsp.buf.references)

local telescope_builtins = require'telescope.builtin'

nmap('<leader>f', telescope_builtins.find_files)
nmap('<leader>g', telescope_builtins.live_grep)
nmap('<leader>b', telescope_builtins.buffers)
nmap('<leader>h', telescope_builtins.help_tags)

-- Move around split windows with less keystrokes
nmap('<c-h>', ':wincmd h<cr>', true)
nmap('<c-j>', ':wincmd j<cr>', true)
nmap('<c-k>', ':wincmd k<cr>', true)
nmap('<c-l>', ':wincmd l<cr>', true)

-- Make working with terminal windows easier
local exit_term = '<c-\\><c-n>'
tmap('<esc>', exit_term, true)
tmap('<c-h>', exit_term..':wincmd h<cr>', true)
tmap('<c-j>', exit_term..':wincmd j<cr>', true)
tmap('<c-k>', exit_term..':wincmd k<cr>', true)
tmap('<c-l>', exit_term..':wincmd l<cr>', true)

-- Create terminal window
nmap('<leader>t', function()
  vim.cmd('new | terminal')
  vim.opt.number = false
  vim.opt.relativenumber = false
  vim.cmd('resize 15 | startinsert')
end)

-- Create split panes
nmap('<leader>v', ':vertical new<cr>', true)
nmap('<leader>x', ':new<cr>', true)
nmap('<leader>o', ':wincmd o<cr>', true)

-- Keybinds with shift
nmap('Y', 'y$') -- Yank to the end
nmap('U', ':redo<cr>') -- Redo

-- Move line up and down
nmap('<a-j>', ':move +1<cr>', true)
nmap('<a-k>', ':move -2<cr>', true)
imap('<a-j>', '<esc>:move +1<cr>a', true)
imap('<a-k>', '<esc>:move -2<cr>a', true)

-- Move selection up and down
vmap('<a-j>', ':move \'>+1<cr>gv', true)
vmap('<a-k>', ':move \'<-2<cr>gv', true)

-- Replace text
nmap('s', ':s//g<left><left>') -- Line
nmap('S', ':%s//g<left><left>') -- All
vmap('s', ':s//g<left><left>') -- Selection

-- Prevent Ctrl-C from canceling block insertion
imap('<c-c>', '<esc>')

-- Toggle light and dark theme
nmap('<c-r>', function()
  if vim.opt.background:get() == 'dark' then
    vim.opt.background = 'light'
  else
    vim.opt.background = 'dark'
  end
end, true)

-- Build project with a command
local make_cmd = vim.opt.makeprg:get()
nmap('<leader>m', function()
  local cmd = vim.fn.input('Build command: ', make_cmd)

  local last_makeprg = vim.opt.makeprg:get()
  local prg, args = cmd:match('%s*(%S+)(.*)')

  if prg == '' or prg == nil then
    return
  end

  vim.opt.makeprg = prg
  vim.cmd('make'..args)

  vim.opt.makeprg = last_makeprg
  make_cmd = cmd
end)

-- Close quickfix and location list
nmap('<leader>cc', ':cclose<cr>', true)
nmap('<leader>lc', ':lclose<cr>', true)

-- Clear hlsearch when move
local search_keys = {}
for _, key in ipairs { "n", "N", "*", "#", "?", "/" } do
  search_keys[key] = true
end

vim.on_key(function(char)
  if vim.fn.mode() == 'n' then
    local hlsearch = search_keys[vim.fn.keytrans(char)] == true

    if vim.opt.hlsearch:get() ~= hlsearch then
      vim.opt.hlsearch = hlsearch
    end
  end
end, nil)
