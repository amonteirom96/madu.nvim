--- Treesitter captures. Most captures fall back to the legacy groups through
--- Neovim's default links, so we only set what the default colorscheme hard-codes
--- plus the captures where style or meaning matters.

---@param c onemono.Colors
---@param o onemono.Config
return function(c, o)
  local s = o.styles
  local fg = c.fg

  local str, func, typ, const = c.code.string, c.code.func, c.code.type, c.code.constant

  ---@param style onemono.Style
  ---@param color? string
  local function with(style, color)
    return vim.tbl_extend("force", { fg = color or fg }, style)
  end

  local function marker(color)
    return { fg = c.bg, bg = color, bold = true }
  end

  local hl = {
    ["@variable"] = with(s.variables),
    ["@variable.builtin"] = with(s.keywords),
    ["@variable.parameter"] = with(s.variables),
    ["@variable.member"] = with(s.variables),

    ["@constant"] = with(s.constants, const),
    ["@constant.builtin"] = with(s.constants, const),
    ["@constant.macro"] = with(s.constants, const),
    ["@number"] = with(s.constants, const),
    ["@number.float"] = with(s.constants, const),
    ["@boolean"] = with(s.constants, const),
    ["@module"] = { fg = fg },
    ["@module.builtin"] = { fg = fg },
    ["@label"] = with(s.keywords),

    ["@string"] = with(s.strings, str),
    ["@string.documentation"] = vim.tbl_extend("force", { fg = o.muted_comments and c.muted or c.comment }, s.comments),
    ["@string.regexp"] = with(s.strings, str),
    ["@string.escape"] = { fg = str, bold = true },
    ["@string.special.url"] = { fg = str, underline = true },
    ["@character"] = with(s.strings, str),
    ["@character.special"] = { fg = str, bold = true },

    ["@type"] = with(s.types, typ),
    ["@type.builtin"] = with(s.types, typ),
    ["@type.definition"] = with(s.types, typ),
    ["@attribute"] = { fg = fg },
    ["@property"] = with(s.variables),

    ["@function"] = with(s.functions, func),
    ["@function.builtin"] = with(s.functions, func),
    ["@function.call"] = with(s.functions, func),
    ["@function.macro"] = with(s.functions, func),
    ["@function.method"] = with(s.functions, func),
    ["@function.method.call"] = with(s.functions, func),
    ["@constructor"] = with(s.types, typ),
    ["@operator"] = with(s.operators),

    ["@keyword"] = with(s.keywords),
    ["@keyword.function"] = with(s.keywords),
    ["@keyword.return"] = with(s.keywords),
    ["@keyword.operator"] = with(s.keywords),

    ["@punctuation"] = { fg = fg },
    ["@punctuation.special"] = { fg = fg },
    ["@tag"] = { fg = fg },
    ["@tag.builtin"] = { fg = fg },
    ["@tag.attribute"] = { fg = fg, italic = true },
    ["@tag.delimiter"] = { fg = fg },

    -- Comment markers. Red only for FIXME/BUG (errors).
    ["@comment.error"] = marker(c.red),
    ["@comment.warning"] = marker(c.yellow),
    ["@comment.todo"] = marker(c.accent),
    ["@comment.note"] = marker(c.cyan),

    -- Markup
    ["@markup.strong"] = { fg = const, bold = true },
    ["@markup.italic"] = { fg = typ, italic = true },
    ["@markup.strikethrough"] = { strikethrough = true },
    ["@markup.underline"] = { underline = true },
    ["@markup.heading"] = { fg = func, bold = true },
    ["@markup.heading.1"] = { fg = func, bold = true },
    ["@markup.heading.2"] = { fg = typ, bold = true },
    ["@markup.heading.3"] = { fg = str, bold = true },
    ["@markup.heading.4"] = { fg = const, bold = true },
    ["@markup.heading.5"] = { fg = func, bold = true },
    ["@markup.heading.6"] = { fg = typ, bold = true },
    ["@markup.heading.1.delimiter.vimdoc"] = { fg = c.muted },
    ["@markup.heading.2.delimiter.vimdoc"] = { fg = c.muted },
    ["@markup.quote"] = { fg = str, italic = true },
    ["@markup.math"] = { fg = const },
    ["@markup.link"] = { fg = func },
    ["@markup.link.label"] = { fg = typ, bold = true },
    ["@markup.link.url"] = { fg = func, underline = true },
    ["@markup.raw"] = { fg = str, bg = c.surface1 },
    ["@markup.raw.block"] = { fg = fg },
    ["@markup.list"] = { fg = const, bold = true },
    ["@markup.list.checked"] = { fg = c.green },
    ["@markup.list.unchecked"] = { fg = c.muted },

    ["@diff.plus"] = { fg = c.git.add },
    ["@diff.minus"] = { fg = c.git.delete },
    ["@diff.delta"] = { fg = c.git.change },
  }
  -- Solarized light keeps markup monochrome; dark retains its four hues.
  if c.variant == "light" then
    hl["@markup.strong"] = { bold = true }
    hl["@markup.italic"] = { italic = true }
    for _, name in ipairs({ "heading", "quote", "math", "link", "link.label", "link.url", "raw", "list" }) do
      hl["@markup." .. name].fg = fg
    end
    for level = 1, 6 do
      hl["@markup.heading." .. level] = nil
    end
  end
  return hl
end
