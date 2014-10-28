emufun = {
  config = { flags = {} };
}

require "lfs"

local init = {}

function state(name)
    return function(...)
        return love.filesystem.load("state/" .. name .. ".lua")(...)
    end
end

function love.load()
  local r,err = xpcall(init.init, debug.traceback)
  if not r then
    print(err)
    os.exit(1)
  end
end

function init.init()
  -- We need to load all the libraries first so that they can register their
  -- command line flags.
  require "util"
  require "logging"
  require "input"
  require "settings"

  flags.register("help", "h", "?") { help = "This text." }

  -- Then we parse the command line the first time around.
  flags.parse(unpack(arg))
  init.argv()

  -- If the user asked for help, we bail here.
  if emufun.config.flags.help then
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

  for k,v in pairs(emufun.config.flags) do
    LOG.DEBUG("FLAG\t%s\t%s", tostring(k), tostring(v))
  end

  -- Now we are done processing the main user config and the command line flags
  -- and can continue with initialization.

  -- Initialize log file.
  if emufun.config.flags.log_file then
    emufun._log = io.open(love.filesystem.getSaveDirectory().."/"..os.time()..".log", "a")
  end

  for k,v in pairs(emufun.config) do
    LOG.DEBUG("CFG\t%s\t%s", tostring(k), tostring(v))
  end

  -- Load image files from disk.
  init.images()

  -- Load user control settings.
  emufun.loadConfig "controls" (setmetatable({ emufun = emufun, love = love }, { __index = input }))

  -- Load top-level library configuration (file types, etc).
  emufun.config._library_config_fn = emufun.loadConfig "library"

  -- Initialize screen.
  init.graphics()

  return state "load-libraries" ()
end

function love.draw() end

function love.update(dt)
  -- cap framerate at 30fps
  love.timer.sleep(1/30 - dt)
end

local _errhand = love.errhand
function love.errhand(...)
  LOG.ERROR("Error: %s", debug.traceback((...)))
  return _errhand(...)
end

function emufun.quit()
  os.exit(0)
end

function init.argv()
  -- Parse command line flags. Flags from argv overwrite anything already present.
  table.merge(emufun.config.flags, flags.parsed)
  -- Flags from the default settings are only taken if nothing has overridden them.
  table.merge(emufun.config.flags, flags.defaults, "ignore")
end

function init.images()
  emufun.images = {}
  for _,file in ipairs(love.filesystem.enumerate "images") do
    if file:match("%.png$") then
      emufun.images[file:sub(1,-5)] = love.graphics.newImage("images/" .. file)
    end
  end
end

function init.graphics()
  -- if the user specified a resolution in emufun.cfg, we use that
  -- otherwise, we get a list of supported modes and use the highest-res one
  -- in this modern age of LCDs, this is usually the same resolution that
  -- the user's desktop is at, thus minimizing disruption
  if emufun.config.fullscreen == nil then
      emufun.config.fullscreen = true
  end
  if emufun.config.width and emufun.config.height then
      love.graphics.setMode(emufun.config.width, emufun.config.height, emufun.config.fullscreen)
  else
    local modes = love.graphics.getModes()
    table.sort(modes, function(x,y) return x.width > y.width or (x.width == y.width and x.height > y.height) end)

    emufun.config.width = modes[1].width
    emufun.config.height = modes[1].height
    love.graphics.setMode(modes[1].width, modes[1].height, emufun.config.fullscreen)
  end

  --love.graphics.setFont("LiberationMono-Bold.ttf", 24)
  love.graphics.setNewFont(math.floor(emufun.config.height/emufun.config.lines) - 8)
  love.graphics.setBackgroundColor(0, 0, 0)
  love.graphics.setCaption("EmuFun")
  love.mouse.setVisible(false)
end
