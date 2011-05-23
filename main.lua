emufun = {}

function load(module)
    return assert(love.filesystem.load(module..".lua"))()
end

require "lfs"

load "util"
load "util"
load "input"
load "node"
load "calibration"
load "gamelist"

function love.load()
    eprintf("Loading user settings: ")
    love.filesystem.load("settings.lua")()
    love.filesystem.write("settings.lua", love.filesystem.read("settings.lua"))
    eprintf("done.\n")
    
    eprintf("Reading game library: ")
    emufun.root = node.new(arg[2] or os.getenv("GAMEDIR") or ".")
    emufun.root:populate()
    for sys in emufun.root:children() do
        sys:populate()
    end
    eprintf("done\n")
    
    eprintf("Setup renderer: ")
    axes = { hat = love.joystick.getHat(0, 0); love.joystick.getAxes(0) }
    
    --love.graphics.setFont("LiberationMono-Bold.ttf", 24)
    love.graphics.setFont(24)
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.setCaption("EmuFun")
    love.mouse.setVisible(false)
    eprintf("done\n")
    
    emufun.calibration()
end

function emufun.quit()
    love.event.push "q"
end

-- q is hardbound to quit
input.key_q = emufun.quit
