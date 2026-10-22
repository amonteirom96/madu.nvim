-- nvim --headless -u NONE --cmd 'set rtp^=.' -l tests/coverage.lua
vim.env.XDG_CACHE_HOME = vim.fn.tempname()
local madu = require("madu")
local function check(value, message) assert(value, message) end
local base = vim.deepcopy(require("madu.palette").base)
local count
for _, variant in ipairs({ "light", "dark" }) do
  for _, cached in ipairs({ false, true }) do
    madu.setup({ cache = cached })
    vim.cmd.colorscheme("madu-" .. variant)
    local c, hl = madu.colors(variant), madu.highlights(variant)
    local function resolved(group) return vim.api.nvim_get_hl(0, { name = group, link = false }) end
    check(vim.deep_equal(base, require("madu.palette").base), "base palette unchanged")
    check(resolved("Normal").bg == tonumber(base[variant].bg:sub(2), 16), "editor bg unchanged")
    check(resolved("MaduPreview").bg ~= resolved("Normal").bg, "substitution preview distinct")
    if variant == "dark" then
      check(resolved("NormalFloat").bg == tonumber(c.surface1:sub(2), 16), "dark float uses existing raised surface")
    end
    for _, group in ipairs({ "TelescopeNormal", "SnacksPickerInputBorder", "NoiceCmdlineIconLua", "CmpItemKindFunction",
      "NeoTreeNormal", "DapStoppedLine", "RenderMarkdownH1Bg", "MiniClueBorder", "LspKindFunction" }) do
      check(hl[group] ~= nil, "missing " .. group)
      check(next(resolved(group)) ~= nil, "unresolved " .. group)
    end
    for _, group in ipairs({ "@tag.tsx", "@variable.parameter.builtin", "@punctuation.bracket", "@markup.raw.markdown_inline" }) do
      local parent = hl[group].link
      check(parent and vim.deep_equal(resolved(group), resolved(parent)), "capture inherits Madu: " .. group)
    end
    for group, spec in pairs(hl) do
      check(spec.style == nil, "unflattened style: " .. group)
      if spec.link then check(spec.link ~= group, "self link: " .. group) end
    end
    count = vim.tbl_count(hl)
  end
  for _, module in ipairs({ "lualine.themes.madu", "lightline.colorscheme.madu" }) do
    package.loaded[module] = nil
    local theme = require(module)
    check(theme.normal and theme.insert and theme.inactive, "statusline modes: " .. module)
    local bg = theme.normal.a and theme.normal.a.bg or theme.normal.left[1][2]
    check(bg == madu.colors(variant).blue, "statusline uses Madu palette: " .. module)
  end
  madu.setup({ transparent = true, cache = false })
  vim.cmd.colorscheme("madu-" .. variant)
  for _, group in ipairs({ "Normal", "NormalFloat", "Pmenu", "TelescopeNormal", "NeoTreeNormal" }) do
    check(vim.api.nvim_get_hl(0, { name = group, link = false }).bg == nil, "transparent " .. group)
  end
  madu.setup({ mono = true, cache = false })
  vim.cmd.colorscheme("madu-" .. variant)
  for _, group in ipairs({ "@constructor.tsx", "@lsp.type.interface", "@lsp.typemod.type.defaultLibrary", "@variable.parameter.builtin" }) do
    check(vim.api.nvim_get_hl(0, { name = group, link = false }).fg == tonumber(madu.colors(variant).fg:sub(2), 16), "mono " .. group)
  end
end
madu.setup({ integrations = { telescope = false, blink = false, mini = false, treesitter = false, semantic_tokens = false } })
local hl = madu.highlights("dark")
for _, group in ipairs({ "TelescopeNormal", "BlinkCmpMenu", "MiniClueBorder", "MiniPickNormal", "@variable", "@lsp.type.interface" }) do
  check(hl[group] == nil, "disabled integration still emits " .. group)
end
madu.setup({ on_highlights = function(groups) groups.TelescopeNormal = { fg = "#123456" } end })
check(madu.highlights("dark").TelescopeNormal.fg == "#123456", "user overrides win")
print(("COVERAGE OK (%d groups per variant)"):format(count))
