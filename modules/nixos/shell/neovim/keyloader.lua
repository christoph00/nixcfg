local M = {}

local io_open = io.open
local string_match = string.match
local vim_notify = vim.notify
local vim_log = vim.log.levels
local vim_env = vim.env

local api_keys = {}
local initialized = false
local current_path = nil

local function parse_key_value(line)
  if string_match(line, "^%s*#") or string_match(line, "^%s*$") then
    return nil, nil
  end
  local key, value = string_match(line, '^%s*([^=%s]+)%s*=%s*"([^"]*)"%s*$')
  return key, value
end

local function safe_load_keys(path)
  local success, result = pcall(function()
    local file, err = io_open(path, "r")
    if not file then
      return nil, "Could not open File: " .. (err or "Unknown Error")
    end

    local keys = {}
    for line in file:lines() do
      local key, value = parse_key_value(line)
      if key and value then
        keys[key] = value
      end
    end
    file:close()
    return keys
  end)
  
  if success then
    return result
  else
    return nil, result
  end
end

local function load_api_keys(path)
  path = path or current_path or "/run/secrets/api-keys"
  
  local keys, err = safe_load_keys(path)
  if keys then
    return keys
  else
    vim_notify("Keyloader Error: " .. err, vim_log.ERROR)
    return {}
  end
end

function M.init_with_path(path)
  if not path then
    vim_notify("Keyloader: path missing ", vim_log.WARN)
    return false
  end
  
  current_path = path
  api_keys = load_api_keys(path)
  initialized = true
  
  if vim.tbl_count(api_keys) > 0 then
    vim_notify("Keyloader: " .. vim.tbl_count(api_keys) .. " Keys loaded", vim_log.INFO)
  else
    vim_notify("Keyloader: no Keys found", vim_log.WARN)
  end
  
  return true
end

local function ensure_initialized()
  if not initialized then
    local paths = {
      vim_env.KEYLOADER_PATH,
      vim_env.API_KEYS_PATH,
      "/run/agenix/api_keys",
      "/run/secrets/api-keys"
    }
    
    for _, path in ipairs(paths) do
      if path and M.init_with_path(path) then
        break
      end
    end
  end
end

function M.get(key_name, default)
  ensure_initialized()
  return api_keys[key_name] or default
end

function M.get_from_env_or_file(key_name, env_var, default)
  env_var = env_var or key_name
  local env_value = vim_env[env_var]
  if env_value then
    return env_value
  end
  return M.get(key_name, default)
end


function M.has(key_name)
  ensure_initialized()
  return api_keys[key_name] ~= nil
end

function M.list()
  ensure_initialized()
  local keys = {}
  for k, _ in pairs(api_keys) do
    table.insert(keys, k)
  end
  return keys
end

function M.status()
  return {
    initialized = initialized,
    current_path = current_path,
    key_count = vim.tbl_count(api_keys),
    available_keys = M.list()
  }
end

function M.setup(opts)
  opts = opts or {}
  
  local secret_path = opts.secret_path or vim_env.KEYLOADER_PATH or "/run/secrets/api-keys"
  
  if M.init_with_path(secret_path) then
    if opts.global_access ~= true then
      _G.keyloader = M
    end
  end
  
  return M
end

function M.reload()
  if current_path then
    return M.init_with_path(current_path)
  else
    vim_notify("Keyloader: missing Path for Reload", vim_log.ERROR)
    return false
  end
end

vim.api.nvim_create_user_command('KeyloaderStatus', function()
  local status = M.status()
  print("Keyloader Status:")
  print("  initialized: " .. tostring(status.initialized))
  print("  current_path: " .. (status.current_path or "not set"))
  print("  total keys: " .. status.key_count)
  if status.key_count > 0 then
    print("  Keys: " .. table.concat(status.available_keys, ", "))
  end
end, { desc = "show Keyloader Status" })

vim.api.nvim_create_user_command('KeyloaderReload', function()
  if M.reload() then
    print("Keyloader reload successfully")
  else
    print("Keyloader Reload failed")
  end
end, { desc = "Reload Keyloader" })

return M
