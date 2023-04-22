local state = {
  macros = {},
  status_bg = nil,
  preview_fg = nil,
  record_key = nil,
  delay_timer = nil,
  queued_macro = nil,
  delay = false,
  notify = true,
  playing = false,
  recording = false,
  macros_loaded = false,
}

function state.get_delay()
  return state.delay
end

function state.get_notify()
  return state.notify
end

function state.get_macros()
  return state.macros
end

function state.get_playing()
  return state.playing
end

function state.get_recording()
  return state.recording
end

function state.get_status_bg()
  return state.status_bg
end

function state.get_preview_fg()
  return state.preview_fg
end

function state.set_delay(delay)
  state.delay = delay
end

function state.get_delay_timer()
  return state.delay_timer
end

function state.set_notify(notify)
  state.notify = notify
end

function state.get_queued_macro()
  return state.queued_macro
end

function state.get_record_key()
  return tostring(state.record_key)
end

function state.set_playing(playing)
  state.playing = playing
end

function state.set_macros(new_macros)
  state.macros = new_macros
end

function state.set_record_key(keymap)
  state.record_key = keymap
end

function state.set_status_bg(status_bg)
  state.status_bg = status_bg
end

function state.set_recording(recording)
  state.recording = recording
end

function state.set_macros_loaded(loaded)
  state.macros_loaded = loaded
end

function state.set_preview_fg(preview_fg)
  state.preview_fg = preview_fg
end

function state.set_delay_timer(delay_timer)
  state.delay_timer = tonumber(delay_timer)
end

function state.set_queued_macro_on_startup()
  if not state.macros_loaded then
    return
  end

  local macros = state.get_macros()
  if macros and macros[1] then
    state.set_queued_macro(macros[1].content)
  end
end

function state.set_queued_macro(macro_content)
  state.queued_macro = macro_content
end

function state.setup(config)
  state.set_notify(config.notify)
  state.set_status_bg(config.status_bg)
  state.set_preview_fg(config.preview_fg)
  state.set_delay_timer(config.delay_timer)
  state.set_record_key(config.keymaps.toggle_record)
end

return state
