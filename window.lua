window = {}

flags.register("fullscreen", "f") {
  help = "Run emufun in fullscreen mode.";
  default = true;
}
flags.register("borderless") {
  help = "Use a borderless fullscreen window rather than switching modes.";
  default = true;
}
flags.register("width") {
  help = "Horizontal resolution when not using borderless fullscreen.";
  default = 0;
  type = flags.number;
}
flags.register("height") {
  help = "Vertical resolution when not using borderless fullscreen.";
  default = 0;
  type = flags.number;
}
flags.register("lines") {
  help = "Number of lines of text to display.";
  default = 25;
  type = flags.number;
}

function window.init()
  -- load image files
  emufun.images = {}
  for _,file in ipairs(love.filesystem.getDirectoryItems "images") do
    if file:match("%.png$") then
      emufun.images[file:sub(1,-5)] = love.graphics.newImage("images/" .. file)
    end
  end

  -- Initialize graphics.
  log.info("Initializing graphics: %dx%d fullscreen=%s borderless=%s",
    emufun.config.width, emufun.config.height,
    tostring(emufun.config.fullscreen), tostring(emufun.config.borderless))
  love.window.setMode(emufun.config.width, emufun.config.height, {
    fullscreen = emufun.config.fullscreen;
    fullscreentype = emufun.config.borderless and "desktop" or "normal";
  })

  love.graphics.setNewFont(math.floor(love.window.getHeight()/emufun.config.lines) - 8)
  love.graphics.setBackgroundColor(0, 0, 0)
  love.mouse.setVisible(false)
end

function window.fullscreen(fs)
  local w,h,flags = love.window.getMode()
  flags.fullscreen = fs
  love.window.setMode(w, h, flags)
end
