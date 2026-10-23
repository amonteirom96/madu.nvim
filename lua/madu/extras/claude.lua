---@type madu.Extra
return {
  ext = ".json",
  render = function(c, _, name)
    local blend = require("madu.util").blend
    return vim.json.encode({
      name = name,
      base = c.variant,
      overrides = {
        claude = c.accent, claudeShimmer = c.azure,
        text = c.fg, inverseText = c.bg, inactive = c.muted, subtle = c.border,
        suggestion = c.accent, permission = c.accent, remember = c.cyan,
        success = c.green, error = c.red, warning = c.yellow,
        promptBorder = c.border, planMode = c.blue, autoAccept = c.green,
        bashBorder = c.orange, ide = c.cyan,
        diffAdded = blend(c.git.add, c.bg, 0.15),
        diffRemoved = blend(c.git.delete, c.bg, 0.15),
        diffAddedWord = blend(c.git.add, c.bg, 0.3),
        diffRemovedWord = blend(c.git.delete, c.bg, 0.3),
        userMessageBackground = c.surface1, userMessageBackgroundHover = c.surface2,
        bashMessageBackgroundColor = c.surface1, memoryBackgroundColor = c.surface1,
        selectionBg = c.surface3, composerSidebarBackground = c.bg_float,
      },
    }) .. "\n"
  end,
}
