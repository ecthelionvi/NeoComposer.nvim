local maps = {}
local map = vim.keymap.set
local opts = { noremap = true, silent = true }
local user_cmd = vim.api.nvim_create_user_command

function maps.setup(config)
  local keymap_config = {
    cycle_next = config.keymaps.cycle_next,
    cycle_prev = config.keymaps.cycle_prev,
    play_macro = config.keymaps.play_macro,
    stop_macro = config.keymaps.stop_macro,
    yank_macro = config.keymaps.yank_macro,
    toggle_record = config.keymaps.toggle_record,
    toggle_macro_menu = config.keymaps.toggle_macro_menu,
  }

  user_cmd("EditMacros", "lua require ('NeoComposer.ui').edit_macros()", {})
  user_cmd("ToggleDelay", "lua require ('NeoComposer.macro').toggle_delay()", {})
  user_cmd("ClearNeoComposer", "lua require ('NeoComposer.store').clear_macros()", {})

  map("n", keymap_config.cycle_next, "<cmd>lua require('NeoComposer.ui').cycle_next()<cr>", opts)
  map("n", keymap_config.cycle_prev, "<cmd>lua require('NeoComposer.ui').cycle_prev()<cr>", opts)
  map("n", keymap_config.yank_macro, "<cmd>lua require('NeoComposer.macro').yank_macro()<cr>", opts)
  map("n", keymap_config.stop_macro, "<cmd>lua require('NeoComposer.macro').halt_macro()<cr>", opts)
  map("n", keymap_config.toggle_record, "<cmd>lua require('NeoComposer.macro').toggle_record()<cr>", opts)
  map("n", keymap_config.play_macro, "<cmd>lua require('NeoComposer.macro').toggle_play_macro()<cr>", opts)
  map("n", keymap_config.toggle_macro_menu, "<cmd>lua require('NeoComposer.ui').toggle_macro_menu()<cr>", opts)
end

return maps
