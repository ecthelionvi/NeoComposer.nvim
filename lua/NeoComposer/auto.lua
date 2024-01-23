local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local auto = {}

function auto.setup()
  local au = augroup("NeoComposer", { clear = true })

  autocmd({ "BufEnter", "BufLeave" }, {
    group = au,
    callback = function()
      pcall(function()
        require("NeoComposer.preview").hide()
      end)
    end,
  })

  autocmd({ "CursorHold", "CursorMoved" }, {
    group = au,
    callback = function()
      pcall(function()
        require("NeoComposer.ui").clear_preview()
      end)
    end,
  })

  autocmd("RecordingEnter", {
    group = au,
    callback = function()
      pcall(function()
        require("NeoComposer.state").set_recording(true)
      end)
    end,
  })

  autocmd("RecordingLeave", {
    group = au,
    callback = function()
      pcall(function()
        require("NeoComposer.state").set_recording(false)
      end)
    end,
  })

  autocmd("VimLeavePre", {
    once = true,
    group = au,
    callback = function()
      pcall(function()
        require("NeoComposer.store").save_macros_to_database()
      end)
    end,
  })

  if vim.v.vim_did_enter == 1 then
    -- Handle lazy-loading the plugin
    pcall(function()
      require("NeoComposer.store").load_macros_from_database()
    end)
    pcall(function()
      require("NeoComposer.state").set_queued_macro_on_startup()
    end)
  else
    autocmd("VimEnter", {
      once = true,
      group = au,
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
end

return auto
