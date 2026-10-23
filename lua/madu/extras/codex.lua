---@type madu.Extra
return {
  ext = ".tmTheme",
  render = function(c, _, name)
    local function settings(values)
      local out = { "<dict>" }
      local keys = vim.tbl_keys(values)
      table.sort(keys)
      for _, key in ipairs(keys) do
        out[#out + 1] = "<key>" .. key .. "</key><string>" .. values[key] .. "</string>"
      end
      out[#out + 1] = "</dict>"
      return table.concat(out, "\n")
    end
    local lines = {
      '<?xml version="1.0" encoding="UTF-8"?>',
      '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">',
      '<plist version="1.0"><dict><key>name</key><string>' .. name .. '</string>',
      '<key>settings</key><array><dict><key>settings</key>',
      settings({ background = c.bg, foreground = c.fg, caret = c.fg, selection = c.surface3 }),
      '</dict>',
    }
    for _, rule in ipairs({
      { "comment", c.comment }, { "string", c.code.string },
      { "entity.name.function, support.function", c.code.func },
      { "entity.name.type, entity.name.class, support.type, support.class", c.code.type },
      { "constant", c.code.constant }, { "keyword, storage, variable", c.fg },
      { "markup.inserted", c.git.add }, { "markup.deleted, invalid", c.git.delete },
      { "markup.changed", c.git.change }, { "markup.heading, markup.underline.link", c.blue },
    }) do
      lines[#lines + 1] = '<dict><key>scope</key><string>' .. rule[1]
        .. '</string><key>settings</key>' .. settings({ foreground = rule[2] }) .. '</dict>'
    end
    lines[#lines + 1] = '</array></dict></plist>'
    return table.concat(lines, "\n") .. "\n"
  end,
}
