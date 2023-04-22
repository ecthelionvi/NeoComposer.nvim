--[[

 /$$   /$$                      /$$$$$$
| $$$ | $$                     /$$__  $$
| $$$$| $$  /$$$$$$   /$$$$$$ | $$  \__/  /$$$$$$  /$$$$$$/$$$$   /$$$$$$   /$$$$$$   /$$$$$$$  /$$$$$$   /$$$$$$
| $$ $$ $$ /$$__  $$ /$$__  $$| $$       /$$__  $$| $$_  $$_  $$ /$$__  $$ /$$__  $$ /$$_____/ /$$__  $$ /$$__  $$
| $$  $$$$| $$$$$$$$| $$  \ $$| $$      | $$  \ $$| $$ \ $$ \ $$| $$  \ $$| $$  \ $$|  $$$$$$ | $$$$$$$$| $$  \__/
| $$\  $$$| $$_____/| $$  | $$| $$    $$| $$  | $$| $$ | $$ | $$| $$  | $$| $$  | $$ \____  $$| $$_____/| $$
| $$ \  $$|  $$$$$$$|  $$$$$$/|  $$$$$$/|  $$$$$$/| $$ | $$ | $$| $$$$$$$/|  $$$$$$/ /$$$$$$$/|  $$$$$$$| $$
|__/  \__/ \_______/ \______/  \______/  \______/ |__/ |__/ |__/| $$____/  \______/ |_______/  \_______/|__/
                                                                | $$
                                                                | $$
                                                                |__/
--]]
local NeoComposer = {}

local auto = require("NeoComposer.auto")
local maps = require("NeoComposer.maps")
local state = require("NeoComposer.state")
local store = require("NeoComposer.store")
local highlight = require('NeoComposer.highlight')

local config = {
  notify = true,
  delay_timer = "150",
  status_bg = "#16161e",
  preview_fg = "#ff9e64",
  keymaps = {
    play_macro = "Q",
    yank_macro = "yq",
    stop_macro = "cq",
    toggle_record = "q",
    cycle_next = "<c-n>",
    cycle_prev = "<c-p>",
    toggle_macro_menu = "<m-q>",
  },
}
function NeoComposer.setup(user_settings)
  if vim.g.neocmoposer_setup then
    return
  end

  vim.g.neocmoposer_setup = true
  user_settings = user_settings or {}

  for k, v in pairs(user_settings) do
    config[k] = v
  end

  auto.setup()
  store.setup()
  highlight.setup()
  maps.setup(config)
  state.setup(config)
end

return NeoComposer
