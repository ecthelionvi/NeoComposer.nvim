-- if not vim.g.neocomposer_setup then
-- require('NeoComposer').setup()
-- end

if vim.g.neocmoposer_setup then
  return
end

require('NeoComposer').setup()

vim.g.neocmoposer_setup = true
