emufun = {}

function load(module)
    return assert(love.filesystem.load(module..".lua"))()
end

require "lfs"

load "util"
load "input"
node = load "node"
load "calibration"
load "loadgames"
load "gamelist"
load "filenotfound"

function love.load()
    eprintf("Loading user settings: ")
    love.filesystem.load("emufun.cfg")()
    love.filesystem.write("emufun.cfg", love.filesystem.read("emufun.cfg"))
    eprintf("done.\n")
    
    eprintf("Setup renderer: ")
    -- if the user specified a resolution in emufun.cfg, we use that
    -- otherwise, we get a list of supported modes and use the highest-res one
    -- in this modern age of LCDs, this is usually the same resolution that
    -- the user's desktop is at, thus minimizing disruption
    if emufun.FULLSCREEN == nil then
        emufun.FULLSCREEN = true
    end
    if emufun.WIDTH and emufun.HEIGHT then
        love.graphics.setMode(emufun.WIDTH, emufun.HEIGHT, emufun.FULLSCREEN)
    else
        local modes = love.graphics.getModes()
        table.sort(modes, function(x,y) return x.width > y.width or (x.width == y.width and x.height > y.height) end)
        
        love.graphics.setMode(modes[1].width, modes[1].height, emufun.FULLSCREEN)
    end
    
    --love.graphics.setFont("LiberationMono-Bold.ttf", 24)
    love.graphics.setNewFont(24)
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.setCaption("EmuFun")
    love.mouse.setVisible(false)
    eprintf("done\n")

    eprintf("Loading images...")
    emufun.images = {}
    for _,file in ipairs(love.filesystem.enumerate "images") do
        if file:match("%.png$") then
            eprintf(file .. " ")
            emufun.images[file:sub(1,-5)] = love.graphics.newImage("images/" .. file)
        end
    end
    eprintf("done.\n")

    return emufun.calibration()
end

function emufun.quit()
    love.event.quit()
end

function emufun.restart()
    load "main"
    return love.load()
end

-- q is hardbound to quit, and r to restart
input.key_q = emufun.quit
input.key_r = emufun.restart
