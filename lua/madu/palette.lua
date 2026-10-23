local util = require("madu.util")

local M = {}

--- Solarized light and Onedark-family dark base palettes. Everything
--- else is derived from these nine colors.
--- `fg` is the color used for code. Four token kinds get a hue: strings (green),
--- functions (blue), types (yellow) and constants/literals (orange), the same
--- colors their LSP kinds use. Keywords, variables and operators stay `fg`.
--- There is no purple or pink, and `red` means *error* and nothing else
--- (diagnostics, error messages, FIXME, git deletions).
---@type table<"light"|"dark", madu.BasePalette>
M.base = {
  light = {
    bg = "#fdf6e3",
    fg = "#52676f",
    red = "#c62d2a",
    orange = "#b64314",
    yellow = "#846400",
    green = "#616f00",
    cyan = "#1e746e",
    azure = "#1e6da5",
    blue = "#1e6da5",
  },
  dark = {
    bg = "#232833", -- essential dark: slate leaning to blue
    fg = "#c5cdd9", -- edge dark: cool off-white
    red = "#f5898e",
    orange = "#e0a06e",
    yellow = "#deb974",
    green = "#a0c980",
    cyan = "#5dbbc1",
    azure = "#96a8ee",
    blue = "#6cb6eb",
  },
}

---@class madu.BasePalette
---@field bg string
---@field fg string
---@field red string
---@field orange string
---@field yellow string
---@field green string
---@field cyan string
---@field azure string
---@field blue string

---@class madu.Colors: madu.BasePalette
---@field variant "light"|"dark"
---@field none "NONE"
---@field bg_float string
---@field surface_float string elevated popup background
---@field bg_dim string      background for inactive windows (dim_inactive)
---@field surface1 string    cursorline, subtle rows
---@field surface2 string    selection, active tab, statusline
---@field surface3 string    stronger selection / match paren
---@field select string      current item in lists: popup menu, pickers, file explorers
---@field border string
---@field muted string       UI chrome only (line numbers, whitespace) — never code
---@field comment string     comments: fg faded toward bg, still WCAG AA
---@field accent string      single UI focal color (matches, prompts)
---@field search string      background for search matches
---@field code { string: string, func: string, type: string, constant: string }  the only hues used in code
---@field git { add: string, change: string, delete: string }
---@field diag { error: string, warn: string, info: string, hint: string, ok: string }

--- Build the full, derived color table for a variant.
---@param variant "light"|"dark"
---@param opts madu.Config
---@return madu.Colors
function M.get(variant, opts)
  local b = vim.deepcopy(M.base[variant])
  local c = b --[[@as madu.Colors]]
  local is_light = variant == "light"
  local blend = util.blend

  c.variant = variant
  c.none = "NONE"

  -- Light follows Solarized neutral surfaces; dark keeps its blue lean.
  local tint = is_light and c.fg or blend(c.azure, c.fg, 0.5)
  c.surface1 = blend(tint, c.bg, is_light and 0.05 or 0.06)
  c.surface2 = blend(tint, c.bg, is_light and 0.08 or 0.085)
  c.surface3 = blend(tint, c.bg, is_light and 0.14 or 0.13)
  -- Current item in every list (Pmenu, pickers, explorers). surface2 is too
  -- faint to spot at a glance, so both variants use surface3 (about the same
  -- perceived lightness step from bg in light and dark).
  c.select = c.surface3
  c.border = blend(tint, c.bg, is_light and 0.24 or 0.22)
  c.muted = blend(c.fg, c.bg, is_light and 0.76 or 0.50)
  -- Comments step back from the code without dropping below AA (4.5:1): fg
  -- with the UI's blue lean, faded toward bg. Italic does the rest.
  c.comment = blend(blend(tint, c.fg, 0.35), c.bg, is_light and 0.95 or 0.7)
  c.bg_dim = is_light and blend(c.fg, c.bg, 0.03) or util.darken(c.bg, 0.12)
  c.bg_float = is_light and c.bg or c.surface1
  -- Raised popups use an existing surface, keeping the palette intact.
  c.surface_float = c.surface1
  -- Git status colors keep their original meaning in monochrome mode.
  c.git = { add = c.green, change = c.blue, delete = c.red }
  -- Keep surfaces intact, but bring text and accents into a narrow tonal range.
  -- Keep 40% of each original hue visible against a neutral anchor.
  -- Apply before the remaining semantic aliases so code, plugins, diagnostics and ANSI agree.
  if opts.mono then
    local neutral = is_light and "#303030" or "#dedede"
    c.fg = neutral
    for _, name in ipairs({ "red", "orange", "yellow", "green", "cyan", "azure", "blue" }) do
      c[name] = blend(c[name], neutral, 0.40)
    end
  end

  -- Use the palette blue for UI matches and prompts.
  c.accent = c.blue
  -- Tinted accent, same hue family as the UI so it stays clean. Stronger than
  -- surface3 so it reads apart from Visual.
  c.search = blend(c.accent, c.bg, is_light and 0.25 or 0.32)

  c.code = {
    string = c.green,
    func = c.blue,
    type = c.yellow,
    constant = c.orange,
  }
  c.diag = { error = c.red, warn = c.yellow, info = c.blue, hint = c.cyan, ok = c.green }

  if opts.on_colors then
    opts.on_colors(c, variant)
  end
  return c
end

return M
