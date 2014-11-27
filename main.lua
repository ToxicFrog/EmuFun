emufun = {
  config = {};
}

package.cpath = package.cpath..";/usr/lib64/lua/5.1/?.so"

function love.update(dt)
  -- cap framerate at 30fps
  love.timer.sleep(1/30 - dt)
end

require "lfs"
require "util"
require "logging"
require "input"
require "settings"
require "window"

flags.register("library-paths", "L") {
    help = "Comma-separated paths to the media library or libraries";
    type = flags.list;
    default = {};
}

local init = {}

function state(name)
    return function(...)
        return love.filesystem.load("state/" .. name .. ".lua")(...)
    end
end

function love.load()
  init.init()
end

function init.init()
  flags.register("help", "h", "?") { help = "This text." }

  -- Then we parse the command line the first time around.
  flags.parse(unpack(arg))
  init.argv()

  -- If the user asked for help, we bail here.
  if emufun.config.help then
    flags.help()
    os.exit(0)
  end

  -- Then we initialize the settings library (which writes default configuration
  -- files, if they don't already exist and this behaviour hasn't been suppressed
  -- with command line options) and then load the user configuration.
  emufun.initConfig()
  emufun.loadConfig "emufun" (emufun.config)

  -- Loading the user configuration may have overwritten the command line flags,
  -- so we parse the command line *again*, giving command line flags precedence
  -- over the user configuration file.
  init.argv()

  -- At this point we finally know what the log file is named, if anything, so
  -- we open it.
  log.init()

  window.init()

  for k,v in pairs(flags.parsed) do
    log.debug("FLAG\t%s\t%s", tostring(k), tostring(v))
  end

  -- Now we are done processing the main user config and the command line flags
  -- and can continue with initialization.

  for k,v in pairs(emufun.config) do
    log.debug("CFG\t%s\t%s", tostring(k), tostring(v))
  end

  -- Load user control settings.
  emufun.loadConfig "controls" (setmetatable({ emufun = emufun, love = love }, { __index = input }))

  -- Load top-level library configuration (file types, etc).
  emufun.config._library_config_fn = emufun.loadConfig "library"

  return state "load-libraries" ()
end

function love.draw() end

local _errhand = love.errhand
function love.errhand(...)
  log.error("Error: %s", debug.traceback((...)))
  return _errhand(...)
end

function emufun.quit()
  os.exit(0)
end

function init.argv()
  -- Parse command line flags. Flags from argv overwrite anything already present.
  table.merge(emufun.config, flags.parsed)
  -- Flags from the default settings are only taken if nothing has overridden them.
  table.merge(emufun.config, flags.defaults, "ignore")
end
