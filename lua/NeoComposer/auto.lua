local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local auto = {}

function auto.setup()
  autocmd({ "BufEnter", "BufLeave" }, {
    group = augroup("NeoComposer", { clear = true }),
    callback = function()
      pcall(function()
        require("NeoComposer.preview").hide()
      end)
    end,
  })

  autocmd({ "CursorHold", "CursorMoved" }, {
    group = "NeoComposer",
    callback = function()
      pcall(function()
        require("NeoComposer.ui").clear_preview()
      end)
      pcall(function()
        require("NeoComposer.ui").clear_preview()
      end)
    end,
  })

  autocmd("RecordingEnter", {
    group = "NeoComposer",
    callback = function()
      pcall(function()
        require("NeoComposer.state").set_recording(true)
      end)
    end,
  })

  autocmd("RecordingLeave", {
    group = "NeoComposer",
    callback = function()
      pcall(function()
        require("NeoComposer.state").set_recording(false)
      end)
    end,
  })

  autocmd("QuitPre", {
    once = true,
    group = "NeoComposer",
    callback = function()
      pcall(function()
        require("NeoComposer.store").save_macros_to_database()
      end)
    end,
  })

  autocmd("VimEnter", {
    once = true,
    group = "NeoComposer",
    callback = function()
      pcall(function()
        require("NeoComposer.store").load_macros_from_database()
      end)
      pcall(function()
        require("NeoComposer.state").set_queued_macro_on_startup()
      end)
    end,
  })
end

return auto
