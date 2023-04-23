local state = require("NeoComposer.state")
local macro = require("NeoComposer.macro")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local actions = require("telescope.actions")
local conf = require("telescope.config").values
local action_state = require("telescope.actions.state")
local entry_display = require("telescope.pickers.entry_display")

local macros = {}

function macros.get_exports()
  return {
    macros = macros.show_macros,
  }
end

function macros.show_macros(opts)
  opts = opts or {}

  pickers
    .new(opts, {
      prompt_title = "NeoComposer Macros",
      finder = macros.generate_new_finder(),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(_, map)
        map("n", "yq", macros.yank_macro)
        map("n", "d", macros.delete_macro)
        map("i", "<cr>", macros.queue_macro)
        map("n", "<cr>", macros.queue_macro)
        map("i", "<c-d>", macros.delete_macro)
        return true
      end,
    })
    :find()
end

function macros.yank_macro(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  macro.yank_macro(selection.value.number)
  actions.close(prompt_bufnr)
end

function macros.prepare_results(macros_table)
  local next = {}
  local idx = 1
  for key, value in pairs(macros_table) do
    if value.name ~= "" then
      value.index = idx
      table.insert(next, value)
      idx = idx + 1
    end
  end

  return next
end

function macros.generate_new_finder()
  return finders.new_table({
    results = macros.prepare_results(state.get_macros()),
    entry_maker = function(entry)
      local displayer = entry_display.create({
        separator = " ",
        items = {
          { width = 2 },
          { width = 80 },
          { remaining = true },
        },
      })

      local macro_number = tostring(entry.number)
      local macro_content = entry.content

      local make_display = function()
        return displayer({
          macro_number,
          macro_content,
        })
      end

      return {
        value = entry,
        ordinal = entry.content,
        display = make_display,
      }
    end,
  })
end

function macros.queue_macro(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  macro.update_and_set_queued_macro(selection.value.number)
  actions.close(prompt_bufnr)
end

function macros.delete_macro(prompt_bufnr)
  local confirmation = vim.fn.input("Delete current macro(s)? [y/n]: ")

  if string.len(confirmation) == 0 or string.sub(string.lower(confirmation), 0, 1) ~= "y" then
    return
  end

  local selection = action_state.get_selected_entry()
  macro.delete_macro(selection.index)

  local current_picker = action_state.get_current_picker(prompt_bufnr)
  current_picker:refresh(macros.generate_new_finder(), { reset_prompt = true })
end

return macros
