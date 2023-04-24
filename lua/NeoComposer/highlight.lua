local highlight = {}

function highlight.setup()
  highlight.timer = vim.loop.new_timer()
  highlight.config = { on_yank = true, timer = 500 }
  highlight.hl_yank = vim.api.nvim_create_namespace("NeoComposerYank")
  vim.api.nvim_set_hl(0, "NeoComposerYanked", { link = "Search", default = true })
end

function highlight.highlight_yank(start_pos, end_pos)
  if not highlight.config.on_yank then
    return
  end

  highlight.timer:stop()
  vim.api.nvim_buf_clear_namespace(0, highlight.hl_yank, 0, -1)

  vim.highlight.range(
    0,
    highlight.hl_yank,
    "NeoComposerYanked",
    start_pos,
    end_pos,
    { regtype = "v", inclusive = true }
  )

  highlight.timer:start(
    highlight.config.timer,
    0,
    vim.schedule_wrap(function()
      vim.api.nvim_buf_clear_namespace(0, highlight.hl_yank, 0, -1)
    end)
  )
end

return highlight
