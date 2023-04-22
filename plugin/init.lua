if vim.g.neocomposer_setup then
  return
end

require('NeoComposer').setup()

vim.g.neocomposer_setup = true
