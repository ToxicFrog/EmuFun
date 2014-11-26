flags.register("overwrite-config") {
  help = "Reset user configuration files to defaults.";
  default = false;
}
flags.register("default-config") {
  help = "Ignore user configuration files and load built-in defaults only.";
  default = false;
}
flags.register("config-dir") {
  help = "Path to user configuration directory.";
  type = flags.string;
  default = love.filesystem.getSaveDirectory() .. "/config/";
}

function emufun.initConfig()
  -- If --default-config is set, we don't have any setup to do.
  if emufun.config.flags.default_config then return end

  -- Copy default configuration into user configuration directory, if we haven't
  -- already. If --overwrite-config set, do this even if we already have.
  local config_dir = emufun.config.flags.config_dir
  if not lfs.exists(config_dir) then
    assert(lfs.rmkdir(config_dir))
  end
  for _,file in ipairs(love.filesystem.getDirectoryItems("default")) do
    local path = "%s/%s" % { config_dir, file }
    log.debug("Checking configuration file: %s", path)
    if emufun.config.flags.overwrite_config or not lfs.exists(path) then
      log.info("Writing new configuration file to user settings directory: %s", path)
      io.writefile(path, love.filesystem.read("default/%s" % file))
    end
  end
end

function emufun.loadConfig(name)
  local default, user = function() end, function() end

  if love.filesystem.exists("default/%s.cfg" % name) then
    log.info("Loading default configuration file %s.cfg", name)
    default = love.filesystem.load("default/%s.cfg" % name)
  end

  local path = "%s/%s.cfg" % { emufun.config.flags.config_dir, name }
  if not emufun.config.flags.default_config and lfs.exists(path) then
    log.info("Loading user configuration file %s", path)
    user = loadfile(path)
  end

  return function(env)
    setfenv(default, env)()
    setfenv(user, env)()
  end
end
