emufun = {}

function load(module)
    return assert(love.filesystem.load(module..".lua"))()
end

require "lfs"

function love.load()
    load "util"
    eprintf("Loading modules: ")
    load "input"
    load "calibration"
    load "loadgames"
    load "gamelist"
    eprintf("done.\n")

    eprintf("Loading images: ")
    emufun.images = {}
    for _,file in ipairs(love.filesystem.enumerate "images") do
        if file:match("%.png$") then
            eprintf(file .. " ")
            emufun.images[file:sub(1,-5)] = love.graphics.newImage("images/" .. file)
        end
    end
    eprintf("done.\n")

    eprintf("Loading user settings: ")
    load "settings"
    eprintf("done.\n")
    
    eprintf("Setup renderer: ")
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
        
        love.graphics.setMode(modes[1].width, modes[1].height, emufun.config.fullscreen)
    end
    
    --love.graphics.setFont("LiberationMono-Bold.ttf", 24)
    love.graphics.setNewFont(24)
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.setCaption("EmuFun")
    love.mouse.setVisible(false)
    eprintf("done\n")

    return emufun.calibration()
end

function emufun.quit()
    love.event.quit()
end

function emufun.restart()
    load "main"
    return love.load()
end
