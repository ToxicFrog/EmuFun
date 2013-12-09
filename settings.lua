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
