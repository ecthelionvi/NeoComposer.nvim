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
local store = require("NeoComposer.store")
local config = require("NeoComposer.config")
local highlight = require("NeoComposer.highlight")

function NeoComposer.setup(user_settings)
  user_settings = vim.tbl_deep_extend("force", config, user_settings or {})

  for k, v in pairs(user_settings) do
    config[k] = v
  end

  store.setup()
  auto.setup()
  highlight.setup()
  maps.setup()
end

return NeoComposer
