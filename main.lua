emufun = {}

require "lfs"

function love.load()
    require "util"
    require "input"

    emufun.images = {}
    for _,file in ipairs(love.filesystem.enumerate "images") do
        if file:match("%.png$") then
            emufun.images[file:sub(1,-5)] = love.graphics.newImage("images/" .. file)
        end
    end

    require "settings"
    
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
