---@type madu.Extra
return {
  ext = ".json",
  render = function(c, _, name)
    local blend = require("madu.util").blend
    return vim.json.encode({
      name = name, type = "custom",
      background = { primary = c.bg, diff = {
        added = blend(c.git.add, c.bg, 0.15), removed = blend(c.git.delete, c.bg, 0.15),
      } },
      text = { primary = c.fg, secondary = c.muted, link = c.blue, accent = c.accent, response = c.fg },
      border = { default = c.border, focused = c.accent },
      status = { success = c.green, warning = c.yellow, error = c.red },
      ui = { comment = c.comment, symbol = c.fg, gradient = { c.blue, c.cyan, c.green } },
    }) .. "\n"
  end,
}
