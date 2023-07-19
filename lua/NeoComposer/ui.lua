local ui = {}

local api = vim.api
local autocmd = api.nvim_create_autocmd
local preview_timer = vim.loop.new_timer()

local popup = require("plenary.popup")
local state = require("NeoComposer.state")
local macro = require("NeoComposer.macro")
local preview = require("NeoComposer.preview")
local highlight = require("NeoComposer.highlight")
local config = require("NeoComposer.config")

BUFH = nil
WIN_ID = nil

function ui.close_menu()
  api.nvim_win_close(WIN_ID, true)
  WIN_ID = nil
  BUFH = nil
end

function ui.close_macro_editor()
  api.nvim_win_close(WIN_ID, true)
  WIN_ID = nil
  BUFH = nil
end

function ui.save_macro_content_in_menu()
  state.set_macros(ui.get_menu_items())
  macro.update_and_set_queued_macro(1, false)
end

function ui.save_macro_content_in_editor()
  state.set_macros(ui.get_menu_items())
  macro.update_and_set_queued_macro(1, false)
end

function ui.cycle_next()
  local new_macros = {}
  local macros = state.get_macros()
  if #macros == 0 then
    return
  end

  for i = 2, #macros do
    table.insert(new_macros, macros[i])
  end

  table.insert(new_macros, macros[1])

  state.set_macros(new_macros)
  preview.show(new_macros[1].content)
  state.set_queued_macro(new_macros[1].content)
end

function ui.cycle_prev()
  local new_macros = {}
  local macros = state.get_macros()
  if #macros == 0 then
    return
  end

  table.insert(new_macros, macros[#macros])

  for i = 1, #macros - 1 do
    table.insert(new_macros, macros[i])
  end

  state.set_macros(new_macros)
  preview.show(new_macros[1].content)
  state.set_queued_macro(new_macros[1].content)
end

function ui.yank_macro_from_menu()
  local line_content = api.nvim_get_current_line()
  local cursor_line = api.nvim_win_get_cursor(WIN_ID)[1]

  if line_content and line_content ~= "" then
    macro.yank_macro(cursor_line)

    local start_col = 0
    local end_col = string.len(line_content)
    local start_pos = { cursor_line - 1, start_col }
    local end_pos = { cursor_line - 1, end_col }
    highlight.highlight_yank(start_pos, end_pos)
  end
end

function ui.select_macro_in_menu()
  local line_content = api.nvim_get_current_line()
  local cursor_line = api.nvim_win_get_cursor(WIN_ID)[1]

  if line_content and line_content ~= "" then
    macro.update_and_set_queued_macro(cursor_line)
  end
  ui.toggle_macro_menu()
end

function ui.get_menu_items()
  local items = {}
  local lines = api.nvim_buf_get_lines(BUFH, 0, -1, true)

  for i, line in ipairs(lines) do
    local stripped_line = line:gsub("%s", "")
    if stripped_line ~= "" then
      table.insert(items, { number = i, content = line })
    end
  end

  if #items == 0 then
    state.set_queued_macro()
  end

  return items
end

function ui.get_bg_color()
  local output = vim.api.nvim_exec("highlight Normal", true)
  local bg_color = output:match("guibg=(#[0-9a-fA-F]+)")
  return bg_color
end

function ui.clear_preview()
  if preview_timer then
    if preview_timer:is_closing() then
      preview_timer = vim.loop.new_timer()
    end
  end
  if preview_timer then
    preview_timer:start(
      1000,
      0,
      vim.schedule_wrap(function()
        preview.hide()
        preview_timer:stop()
        if not preview_timer:is_closing() then
          preview_timer:close()
        end
      end)
    )
  end
end

function ui.create_window()
  local width = 60
  local height = 10
  local bufnr = api.nvim_create_buf(false, false)
  local border_chars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }

  local WIN_ID, win = popup.create(bufnr, {
    minwidth = width,
    minheight = height,
    title = "NeoComposer",
    borderchars = border_chars,
    col = math.floor((vim.o.columns - width) / 2),
    line = math.floor(((vim.o.lines - height) / 2) - 1),
  })

  local bg_color = ui.get_bg_color()
  vim.cmd(string.format("highlight ComposerNormal guibg=%s", bg_color))

  api.nvim_win_set_option(WIN_ID, "winhl", "Normal:ComposerNormal")
  api.nvim_win_set_option(win.border.win_id, "winhl", "Normal:ComposerBorder")

  return {
    bufnr = bufnr,
    win_id = WIN_ID,
  }
end

function ui.status_recording()
  local function set_highlight(group, fg, bg)
    vim.cmd(string.format("highlight %s guifg=%s guibg=%s", group, fg, bg))
  end

  set_highlight("DelaySymbol", config.colors.blue, config.colors.bg)
  set_highlight("PlayingSymbol", config.colors.green, config.colors.bg)
  set_highlight("RecordingSymbol", config.colors.red, config.colors.bg)

  local status = ""
  local delay_enabled = state.get_delay()

  if state.get_recording() then
    status = "%#RecordingSymbol#%* REC"
  elseif state.get_playing() then
    status = "%#PlayingSymbol#%* PLAY"
  end

  if delay_enabled then
    status = (status == "" and "" or (status .. " ")) .. "%#DelaySymbol#󰔛%* DELAY"
  end

  return status
end

function ui.toggle_macro_menu()
  if WIN_ID and api.nvim_win_is_valid(WIN_ID) then
    ui.close_menu()
    return
  end

  local win_info = ui.create_window()
  WIN_ID, BUFH = win_info.win_id, win_info.bufnr

  local contents = {}
  for i, m in ipairs(state.get_macros()) do
    contents[i] = m.content
  end

  local function map(mode, lhs, rhs)
    api.nvim_buf_set_keymap(BUFH, mode, lhs, rhs, { silent = true })
  end

  api.nvim_win_set_option(WIN_ID, "number", true)
  api.nvim_buf_set_name(BUFH, "neocomposer-menu")
  api.nvim_buf_set_option(BUFH, "buftype", "acwrite")
  api.nvim_buf_set_option(BUFH, "bufhidden", "delete")
  api.nvim_buf_set_lines(BUFH, 0, #contents, false, contents)

  map("n", "q", "<Cmd>lua require('NeoComposer.ui').toggle_macro_menu()<CR>")
  map("n", "yq", "<Cmd>lua require('NeoComposer.ui').yank_macro_from_menu()<CR>")
  map("n", "<ESC>", "<Cmd>lua require('NeoComposer.ui').toggle_macro_menu()<CR>")
  map("n", "<CR>", "<Cmd>lua require('NeoComposer.ui').select_macro_in_menu()<CR>")

  autocmd("BufLeave", {
    once = true,
    nested = true,
    buffer = BUFH,
    group = "NeoComposer",
    callback = function()
      pcall(require("NeoComposer.ui").toggle_macro_menu)
    end,
  })

  autocmd({ "InsertLeave", "TextChanged" }, {
    nested = true,
    buffer = BUFH,
    group = "NeoComposer",
    callback = function()
      pcall(require("NeoComposer.ui").save_macro_content_in_menu)
    end,
  })
end

function ui.edit_macros()
  local bufnr = api.nvim_create_buf(false, true)
  local win_id = api.nvim_open_win(bufnr, true, {
    relative = "editor",
    width = vim.o.columns,
    height = vim.o.lines,
    col = 0,
    row = 0,
    style = "minimal",
  })

  local bg_color = ui.get_bg_color()
  vim.cmd(string.format("highlight MacroEditorNormal guibg=%s", bg_color))
  api.nvim_win_set_option(win_id, "winhl", "Normal:MacroEditorNormal")

  api.nvim_win_set_option(win_id, "number", true)
  api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")

  local macros = state.get_macros()
  local contents = {}
  for i, m in ipairs(macros) do
    contents[i] = m.content
  end
  api.nvim_buf_set_lines(bufnr, 0, -1, false, contents)

  local function map(mode, lhs, rhs)
    api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, { silent = true })
  end
  map("n", "q", "<Cmd>lua require('NeoComposer.ui').close_macro_editor()<CR>")
  map("n", "yq", "<Cmd>lua require('NeoComposer.ui').yank_macro_from_menu()<CR>")
  map("n", "<ESC>", "<Cmd>lua require('NeoComposer.ui').close_macro_editor()<CR>")

  autocmd("BufLeave", {
    once = true,
    nested = true,
    buffer = bufnr,
    group = "NeoComposer",
    callback = function()
      pcall(require("NeoComposer.ui").close_macro_editor)
    end,
  })

  autocmd({ "InsertLeave", "TextChanged" }, {
    nested = true,
    buffer = bufnr,
    group = "NeoComposer",
    callback = function()
      pcall(require("NeoComposer.ui").save_macro_content_in_editor)
    end,
  })

  BUFH = bufnr
  WIN_ID = win_id
end

return ui
