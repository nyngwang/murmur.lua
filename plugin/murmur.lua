if vim.fn.has("nvim-0.5") == 0 then
  return
end

if vim.g.loaded_murmur ~= nil then
  return
end

require('murmur')

vim.g.loaded_murmur = 1
