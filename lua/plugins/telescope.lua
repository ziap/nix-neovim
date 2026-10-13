local telescope = require'telescope'

local layout_strategies = require('telescope.pickers.layout_strategies')

layout_strategies.custom = function(picker, max_columns, max_lines, layout_config)
  local layout = layout_strategies.horizontal(picker, max_columns, max_lines, layout_config)

  layout.preview.title = 'Preview'

  layout.results.title = ''
  layout.results.borderchars = { '─', '│', '─', '│', '├', '┤', '╯', '╰' }
  layout.results.line = layout.results.line - 1
  layout.results.height = layout.results.height + 1

  return layout
end

telescope.setup {
  defaults = {
    path_display = { 'filename_first' },
    layout_strategy = 'custom',
    layout_config = {
      prompt_position = 'top',
      horizontal = {
        width = 0.8,
        preview_width = 15 / 32,
      },
    },
    sorting_strategy = 'ascending',
  },
}
telescope.load_extension('fzf')
