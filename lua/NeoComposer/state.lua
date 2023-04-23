local state = {
  macros = {},
  record_key = nil,
  queued_macro = nil,
  delay = false,
  playing = false,
  recording = false,
  macros_loaded = false,
}

function state.get_delay()
  return state.delay
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

function state.set_delay(delay)
  state.delay = delay
end

function state.get_queued_macro()
  return state.queued_macro
end

function state.set_playing(playing)
  state.playing = playing
end

function state.set_macros(new_macros)
  state.macros = new_macros
end

function state.set_recording(recording)
  state.recording = recording
end

function state.set_macros_loaded(loaded)
  state.macros_loaded = loaded
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

return state
