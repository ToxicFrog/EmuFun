window = {}

function window.init()
  -- load image files
  emufun.images = {}
  for _,file in ipairs(love.filesystem.getDirectoryItems "images") do
    if file:match("%.png$") then
      emufun.images[file:sub(1,-5)] = love.graphics.newImage("images/" .. file)
    end
  end

  -- initialize graphics mode
  -- if the user specified a resolution in emufun.cfg, we use that
  -- otherwise, conf.lua has already set things up for us properly: borderless
  -- fullscreen at desktop resolution.
  if emufun.config.fullscreen == nil then
      emufun.config.fullscreen = true
  end
  if emufun.config.width and emufun.config.height then
      love.window.setMode(emufun.config.width, emufun.config.height, {
        fullscreen = emufun.config.fullscreen;
        -- "desktop" doesn't work if the user wants a resolution other than desktop res
        -- and if they *did* want that, they just need to leave things at the defaults
        fullscreentype = "normal";
      })
  else
    emufun.config.width,emufun.config.height = love.graphics.getDimensions()
    emufun.config.fullscreen = false -- borderless doesn't require toggleFullscreen()
  end

  --love.graphics.setFont("LiberationMono-Bold.ttf", 24)
  love.graphics.setNewFont(math.floor(emufun.config.height/emufun.config.lines) - 8)
  love.graphics.setBackgroundColor(0, 0, 0)
  love.mouse.setVisible(false)
end

function window.fullscreen(fs)
  local w,h,flags = love.window.getMode()
  flags.fullscreen = fs
  love.window.setMode(w, h, flags)
end
