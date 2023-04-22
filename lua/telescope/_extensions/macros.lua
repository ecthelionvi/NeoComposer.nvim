local get_exports = require("NeoComposer.telescope.macros").get_exports

local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
  return
end

return telescope.register_extension({
  exports = get_exports(),
})
