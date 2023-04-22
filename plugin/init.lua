-- if not vim.g.neocomposer_setup then
-- require('NeoComposer').setup()
-- end

if vim.g.neocomposer_setup then
  return
end

require('NeoComposer').setup()

vim.g.neocomposer_setup = true
