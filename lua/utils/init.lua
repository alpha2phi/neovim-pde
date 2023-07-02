local M = {}

function M.has(plugin)
  return require("lazy.core.config").plugins[plugin] ~= nil
end

return M
