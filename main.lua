emufun = { config = { flags = {
  -- default command line flag settings
  default_config = true;
  user_config = true;
  write_user_config = true;
  overwrite_config = false;
}}}

require "lfs"

local init = {}

function love.load()
  -- Process command line. Some flags affect library loading and config file reading.
  init.argv()

  -- Load the LOG functions. They won't do anything until enabled by the user settings or command line.
  require "util"
  require "logging"
  require "input"
  require "settings"

  -- Load settings library and user settings file.
  emufun.load_config "emufun" (emufun.config)

  -- Process command line *again*. This allows command line flags to override config file contents.
  init.argv()

  for k,v in pairs(emufun.config.flags) do
    LOG.DEBUG("FLAG\t%s\t%s", tostring(k), tostring(v))
  end

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
  emufun.load_config "controls" (setmetatable({ emufun = emufun, love = love }, { __index = input }))

  -- Load top-level library configuration (file types, etc).
  emufun.config._library_config_fn = emufun.load_config "library"

  -- Initialize screen.
  init.graphics()

  return state "load-libraries" ()
end

function love.draw() end

function love.update(dt)
  -- cap framerate at 30fps
  love.timer.sleep(1/30 - dt)
end

function emufun.quit()
  os.exit(0)
end

function init.argv()
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
