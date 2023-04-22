local preview = {}
local state = require("NeoComposer.state")

local preview_fg = state.get_preview_fg()
local preview_ns = vim.api.nvim_create_namespace("Preview")

vim.cmd('highlight Preview guifg= ' .. preview_fg)

function preview.show(text)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1], cursor[2]

  vim.api.nvim_buf_clear_namespace(0, preview_ns, 0, -1)

  local opts = {
    virt_text = { { text, "Preview" } },
  }

  vim.api.nvim_buf_set_extmark(0, preview_ns, row - 1, col, opts)
end

function preview.hide()
  vim.api.nvim_buf_clear_namespace(0, preview_ns, 0, -1)
end

return preview
