local store = {
  db = nil,
}

local status_ok, connection = pcall(require, "sqlite")
if not status_ok then
  print("Error: [sqlite.lua] not found")
  return
end

function store.clear_macros()
  require("NeoComposer.state").set_macros({})

  store.db:with_open(function()
    store.db:delete("macros")
  end)
end

function store.save_macros_to_database()
  local macros = require("NeoComposer.state").get_macros()
  store.clear_macros()

  store.db:with_open(function()
    for _, macro in ipairs(macros) do
      store.db:insert("macros", {
        number = macro.number,
        content = macro.content
      })
    end
  end)
end

function store.setup()
  local dbpath = vim.fn.stdpath("cache") .. "/NeoComposer/macros.db"
  vim.fn.mkdir(string.match(dbpath, "(.*[/\\])"), "p")

  store.db = connection:open(dbpath)
  if not store.db then
    vim.notify("Error in opening DB", vim.log.levels.ERROR)
    return
  end

  store.db:with_open(function()
    if not store.db:exists("macros") then
      store.db:execute([[
        CREATE TABLE IF NOT EXISTS macros (
          number INTEGER,
          content TEXT
        )
      ]])
    end
  end)
end

function store.load_macros_from_database()
  local macros = {}
  if require("NeoComposer.state").macros_loaded then return end

  store.db:with_open(function()
    local results = store.db:select("macros", { order_by = { asc = "number" } })
    for _, macro in ipairs(results) do
      table.insert(macros, {
        content = macro.content,
        number = macro.number
      })
    end
  end)

  require("NeoComposer.state").set_macros(macros)
  require("NeoComposer.state").set_macros_loaded(true)
end

return store
