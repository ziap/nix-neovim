require'blink.cmp'.setup {
  keymap = {
    preset = 'none',

    ['<C-space>'] = { 'show', 'select_and_accept' },

    ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
    ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },

    ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
    ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
  },

  appearance = {
    nerd_font_variant = 'mono',
  },

  completion = {
    documentation = { auto_show = true },
  },

  signature = {
    enabled = true,
  },
}
