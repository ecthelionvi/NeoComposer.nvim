local maps = {}
local map = vim.keymap.set
local opts = { noremap = true, silent = true }
local user_cmd = vim.api.nvim_create_user_command
local config = require("NeoComposer.config")

function maps.setup()
  user_cmd("EditMacros", "lua require ('NeoComposer.ui').edit_macros()", {})
  user_cmd("ToggleDelay", "lua require ('NeoComposer.macro').toggle_delay()", {})
  user_cmd("ClearNeoComposer", "lua require ('NeoComposer.store').clear_macros()", {})

  map("n", config.keymaps.cycle_next, "<cmd>lua require('NeoComposer.ui').cycle_next()<cr>", opts)
  map("n", config.keymaps.cycle_prev, "<cmd>lua require('NeoComposer.ui').cycle_prev()<cr>", opts)
  map("n", config.keymaps.yank_macro, "<cmd>lua require('NeoComposer.macro').yank_macro()<cr>", opts)
  map("n", config.keymaps.stop_macro, "<cmd>lua require('NeoComposer.macro').halt_macro()<cr>", opts)
  map("n", config.keymaps.toggle_record, "<cmd>lua require('NeoComposer.macro').toggle_record()<cr>", opts)
  map({ "n", "x" }, config.keymaps.play_macro, "<cmd>lua require('NeoComposer.macro').toggle_play_macro()<cr>", opts)
  map("n", config.keymaps.toggle_macro_menu, "<cmd>lua require('NeoComposer.ui').toggle_macro_menu()<cr>", opts)
end

return maps
