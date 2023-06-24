local macro = {}

local fn = vim.fn
local cmd = vim.cmd
local state = require("NeoComposer.state")
local preview = require("NeoComposer.preview")
local config = require("NeoComposer.config")

STOP_MACRO = false

function macro.record_macro()
  fn.setreg("q", "")
  cmd("silent! normal! qq")
  state.set_recording(true)
  macro.notify("recording")
end

function macro.toggle_record()
  if state.get_recording() then
    macro.stop_macro()
  else
    macro.record_macro()
  end
end

function macro.toggle_play_macro()
  local delay = state.get_delay()
  if not macro.valid_queue() then
    return
  end
  if not delay then
    macro.play_macro()
  else
    macro.play_macro_with_delay()
  end
  preview.hide()
end

function macro.toggle_delay()
  local delay = state.get_delay()
  state.set_delay(not delay)
  if not delay then
    macro.notify("delay")
  else
    macro.notify("delay_disabled")
  end
end

function macro.renumber_macros()
  local macros = state.get_macros()
  local index = 1
  for _, m in ipairs(macros) do
    m.number = index
    index = index + 1
  end
  state.set_macros(macros)
end

function macro.next_macro_number()
  local macros = state.get_macros()
  local max_number = 0
  for _, m in pairs(macros) do
    if m.number > max_number then
      max_number = m.number
    end
  end
  return max_number + 1
end

function macro.halt_macro()
  if state.get_playing() then
    STOP_MACRO = true
    state.set_playing(false)
  end
end

function macro.execute_macro()
  fn.setreg("@", state.get_queued_macro())
  cmd('silent! noautocmd normal! @"')
end

function macro.valid_queue()
  if state.get_recording() then
    return false
  end

  local queued_macro_content = state.get_queued_macro()
  if not queued_macro_content then
    macro.notify("queue_empty")
    return false
  end
  return true
end

function macro.yank_macro(macro_number)
  local macros = state.get_macros()

  local function yank(macro_content)
    local decoded_macro = vim.fn.keytrans(macro_content)
    vim.api.nvim_command("let @" .. "+ = '" .. decoded_macro:gsub("'", "''") .. "'")
    vim.api.nvim_command("let @" .. "* = '" .. decoded_macro:gsub("'", "''") .. "'")
    vim.api.nvim_command("let @" .. '"' .. " = '" .. decoded_macro:gsub("'", "''") .. "'")
    macro.notify("yanked", decoded_macro)
  end

  if macro_number then
    for _, m in ipairs(macros) do
      if m.number == macro_number then
        yank(m.content)
        break
      end
    end
  else
    if state.get_queued_macro() then
      yank(state.get_queued_macro())
    end
  end
end

function macro.delete_macro(macro_number)
  local macros = state.get_macros()

  local deleted_macro_content = macros[macro_number].content
  table.remove(macros, macro_number)
  macro.renumber_macros()

  if state.get_queued_macro() == deleted_macro_content then
    state.set_queued_macro(nil)
  end

  state.set_macros(macros)
end

local function get_count()
  if string.lower(vim.api.nvim_get_mode().mode) == "v" then
    local curpos = vim.fn.getpos(".")
    local vispos = vim.fn.getpos("v")
    return math.abs(curpos[2] - vispos[2]) + 1
  end

  local count = tonumber(vim.v.count) or 1
  return count > 0 and count or 1
end

local function start_pos_in_selection()
  local start = vim.fn.getpos("v")
  local end_ = vim.fn.getpos(".")
  local start_row = start[2]
  local end_row = end_[2]
  local start_col = start[3]
  local end_col = end_[3]

  if end_row < start_row then
    start_row, end_row = end_row, start_row
    start_col, end_col = end_col, start_col
  end

  return { start_row, start_col }
end

local function enter_normal_mode()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "x", false)
end

function macro.play_macro()
  local count = get_count()
  local timer = vim.loop.new_timer()
  local current_count = 0

  local start_pos = start_pos_in_selection()
  enter_normal_mode()
  vim.api.nvim_win_set_cursor(0, start_pos)

  state.set_playing(true)
  STOP_MACRO = false

  local function loop_macro()
    if current_count < count and not STOP_MACRO then
      current_count = current_count + 1
      macro.execute_macro()
      loop_macro()
    end
  end

  local success, result = pcall(loop_macro)

  if success then
    if timer then
      timer:start(
        150,
        0,
        vim.schedule_wrap(function()
          state.set_playing(false)
        end)
      )
    end
  else
    state.set_playing(false)
    macro.notify("error", result)
  end
end

function macro.update_and_set_queued_macro(macro_number, saved)
  local prev_queued_macro = state.get_queued_macro()
  local macros = state.get_macros()
  local updated_macros = {}
  local queued_macro = nil

  for _, m in ipairs(macros) do
    if m.number == macro_number then
      queued_macro = { number = 1, content = m.content }
    else
      table.insert(updated_macros, m)
    end
  end

  if queued_macro then
    if queued_macro.content == prev_queued_macro then
      return
    end

    table.insert(updated_macros, 1, queued_macro)
    for i, m in ipairs(updated_macros) do
      m.number = i
    end
  end

  if not saved then
    macro.notify("queued", queued_macro.content)
  end

  state.set_macros(updated_macros)
  state.set_queued_macro(queued_macro.content)
end

function macro.play_macro_with_delay()
  local count = get_count()
  local timer = vim.loop.new_timer()

  local start_pos = start_pos_in_selection()
  enter_normal_mode()
  vim.api.nvim_win_set_cursor(0, start_pos)

  STOP_MACRO = false
  local current_count = 0
  state.set_playing(true)

  local function delay_macro()
    if current_count < count and not STOP_MACRO then
      current_count = current_count + 1
      macro.execute_macro()
      if timer then
        timer:start(config.delay_timer, 0, vim.schedule_wrap(delay_macro))
      end
    else
      if timer then
        timer:stop()
      end
      state.set_playing(false)
    end
  end

  local success, result = pcall(function()
    if timer then
      timer:start(config.delay_timer, 0, vim.schedule_wrap(delay_macro))
    end
  end)

  if not success then
    if not STOP_MACRO then
      state.set_playing(false)
    end
    macro.notify("error", result)
  end
end

function macro.filter_keymap(macro_content)
  local decode_key = fn.keytrans(tostring(config.keymaps.toggle_record))
  local filtered_macro = macro_content:sub(1, -1 * (#decode_key + 1))
  return filtered_macro
end

function macro.stop_macro()
  cmd("silent! normal! q")
  state.set_recording(false)
  local macro_content = fn.getreg("q")
  local stripped_macro = macro_content:gsub("%s", "")
  if stripped_macro == tostring(config.keymaps.toggle_record) then
    macro.notify("recording_comlete_empty")
    return
  end
  local macros = state.get_macros()
  local macro_number = macro.next_macro_number()
  local filtered_macro_content = macro.filter_keymap(macro_content)
  macro.notify("recording_comlete", filtered_macro_content)

  table.insert(macros, { number = macro_number, content = filtered_macro_content })
  state.set_macros(macros)

  if macro_number == 1 then
    macro.update_and_set_queued_macro(macro_number, true)
  end
end

function macro.notify(switch, macro_content)
  if not config.notify then
    return
  end
  local messages = {
    yanked = "Yanked ",
    error = "Macro Error: ",
    queued = "Macro Queued ",
    queue_empty = "Queue Empty",
    recording = "Macro Recording",
    delay_disabled = "Delay Disabled",
    recording_comlete = "Macro Saved ",
    recording_comlete_empty = "Macro Saved (Empty)",
    delay = "Delay Enabled (Timer: " .. config.delay_timer .. "ms)",
  }

  local message = messages[switch]
  if message then
    if
      switch == "playing"
      or switch == "recording_comlete"
      or switch == "queued"
      or switch == "error"
      or switch == "yanked"
    then
      local truncated_macro = (tostring(macro_content)):sub(1, 30)
      message = message .. "(" .. truncated_macro .. (macro_content:len() > 30 and "..." or "") .. ")"
    end
    vim.notify(message, vim.log.levels.INFO, { title = "NeoComposer" })
  end
end

return macro
