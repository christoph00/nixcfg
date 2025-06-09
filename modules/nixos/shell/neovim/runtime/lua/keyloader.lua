local M = {}
local keys = {}

function M.load_keys(path)
  local file = io.open(path, "r")
  if not file then
    vim.notify("Keyloader: Path not Found: " .. path, vim.log.levels.WARN)
    return false
  end

  keys = {}
  for line in file:lines() do
    if not line:match("^%s*#") and not line:match("^%s*$") then
      local key, value = line:match('^%s*([^=%s]+)%s*=%s*"([^"]*)"%s*$')
      if key and value then
        keys[key] = value
      end
    end
  end
  file:close()
  
  vim.notify("Keyloader: " .. vim.tbl_count(keys) .. " Keys loaded", vim.log.levels.INFO)
  return true
end

function M.get(key_name, default)
  return keys[key_name] or default
end

function M.get_env(key_name, env_var, default)
  return vim.env[env_var or key_name] or M.get(key_name, default)
end

function M.has(key_name)
  return keys[key_name] ~= nil
end

function M.list()
  return vim.tbl_keys(keys)
end

function M.set_globals()
  for key, value in pairs(keys) do
    vim.g[key:lower()] = value
  end
end

return M

