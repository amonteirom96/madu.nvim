if vim.g.loaded_madu then
  return
end
vim.g.loaded_madu = true

local cmd = vim.api.nvim_create_user_command

cmd("MaduCompile", function()
  require("madu").compile()
end, { desc = "madu: rebuild the compiled highlight cache" })

cmd("MaduClearCache", function()
  require("madu").clear_cache()
end, { desc = "madu: delete the compiled highlight cache" })

cmd("MaduExtras", function(args)
  local out = require("madu").extras(args.args ~= "" and args.args or nil)
  vim.notify("madu: extras written to " .. out)
end, { nargs = "?", complete = "dir", desc = "madu: generate ghostty/kitty/lazygit themes" })
