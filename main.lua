emufun = {}

require "lfs"
require "util"
require "input"
require "node"
require "calibration"
require "gamelist"
require "settings"

function love.load()
    eprintf("Reading game library:")
    emufun.root = node.new(os.getenv("GAMEDIR"))
    emufun.root:populate()
    for sys in emufun.root:children() do
        sys:populate()
    end
    eprintf(" done\n")
    
    eprintf("Setup renderer:")
    axes = { hat = love.joystick.getHat(0, 0); love.joystick.getAxes(0) }
    
    --love.graphics.setFont("LiberationMono-Bold.ttf", 24)
    love.graphics.setFont(24)
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.setCaption("EmuFun")
    love.mouse.setVisible(false)
    
    eprintf(" done\n")
    emufun.calibration()
end

function emufun.quit()
    love.event.push "q"
end

-- q is hardbound to quit
input.key_q = emufun.quit
