-- create baked-in default configuration including command line flags
emufun.config = {}
emufun.config.flags = {
  default_config = true;
  user_config = true;
  write_user_config = true;
  overwrite_config = false;
}

-- parse command line flags
local function parse_flag(flag, pattern, value)
  name = flag:match(pattern)
  if name then
    emufun.config.flags[name:gsub("-", "_")] = value
    return true
  end
end

for _,arg in pairs(arg) do
  if not (parse_flag(arg, "^%+(%w)", false)
          or parse_flag(arg, "^%-%-no%-(%S+)", false)
          or parse_flag(arg, "^%-(%w)", true)
          or parse_flag(arg, "^%-%-(%S+)", true))
  then
    table.insert(emufun.config.flags, flag)
  end
end

for k,v in pairs(emufun.config.flags) do
  LOG.DEBUG("FLAG", k, v)
end

-- Copy default configuration into user config dir, if we haven't already yet
-- and if --write-user-config is still set.
-- TODO: write blank files with default settings documented, let user override.
if emufun.config.flags.write_user_config then
  love.filesystem.mkdir("config")
  for _,file in ipairs(love.filesystem.enumerate("default")) do
    LOG.DEBUG("Checking configuration file:", file)
    if not love.filesystem.exists("config/"..file) or emufun.config.flags.overwrite_config then
      LOG.INFO("Writing new configuration file to user settings directory:", file)
      love.filesystem.write("config/"..file, love.filesystem.read("default/"..file))
    end
  end
end

function emufun.load_config(name)
  local default, user = function() end, function() end

  if emufun.config.flags.default_config and love.filesystem.exists("default/%s.cfg" % name) then
    default = love.filesystem.load("default/%s.cfg" % name)
  end

  if emufun.config.flags.user_config and love.filesystem.exists("config/%s.cfg" % name) then
    user = love.filesystem.load("config/%s.cfg" % name)
  end

  return function(env)
    setfenv(default, env)()
    setfenv(user, env)()
  end
end

emufun.load_config "emufun" (emufun.config)
emufun.load_config "controls" (setmetatable({ emufun = emufun, love = love }, { __index = input }))

-- load library file type configuration for later use by library state
emufun.config._library_config_fn = emufun.load_config "library"
