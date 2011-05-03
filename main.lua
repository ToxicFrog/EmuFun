function eprintf(...)
    return io.stderr:write(string.format(...))
end

local systems = {}
local configs = {}

local currentSystemIndex
local currentSystem

input = {}

function love.load()
    love.filesystem.load("input.lua")()
    
    for line in io.lines() do
        -- is it a configuration file?
        if line:match("%.config$") then
            local system,config = line:match("[./]*([^/]+)/(.*)")
            configs[system] = configs[system] or {}
            configs[system][config] = true
        else
            local system,rom = line:match("[./]*([^/]+)/(.*)")
            if not systems[system] then
                systems[system] = systems[system] or { name = system, game = 1 }
                table.insert(systems, systems[system])
            end
            table.insert(systems[system], rom)
        end
    end
    
    table.sort(systems, function(x,y) return x.name < y.name end)
    
    for _,roms in ipairs(systems) do
        table.sort(roms)
    end
    
    currentSystemIndex = 1  
    currentSystem = systems[1]
    
    axes = { hat = love.joystick.getHat(0, 0); love.joystick.getAxes(0) }
    
    --love.graphics.setFont("LiberationMono-Bold.ttf", 24)
    love.graphics.setFont(24)
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.setCaption("EmuFun")
    love.mouse.setVisible(false)
end

-- "baseline" UI commands
-- the gamepad binding code actually just copies these functions into
-- the correct fields
function input.key_q()
    love.event.push "q"
end

function input.key_up()
    currentSystem.game = (currentSystem.game - 2) % #currentSystem + 1
end

function input.key_down()
    currentSystem.game = currentSystem.game % #currentSystem + 1
end

function input.key_left()
    currentSystemIndex = (currentSystemIndex - 2) % #systems + 1
    currentSystem = systems[currentSystemIndex]
end

function input.key_right()
    currentSystemIndex = currentSystemIndex % #systems + 1
    currentSystem = systems[currentSystemIndex]
end

function input.key_enter()
end

function input.key_enter()
    -- find configuration file for this ROM
    -- output path to ROM and path to matching config file
    local sys = currentSystem.name
    local rom = currentSystem[currentSystem.game]
    local cfg = rom
    
    while not configs[sys][cfg..".config"] do
        cfg = cfg:match("(.-)%.?[^.]+$")
    end
    
    print(sys.."/"..cfg..".config")
    print(currentSystem.name.."/"..rom)
    
    input.key_q()
end


state = {}

function state.main()
    input.key_any = nil
    input.joy_any = nil
    
    function love.draw()
        local lg = love.graphics
        local clip = lg.setScissor
        
        -- decorations at top
        lg.triangle("fill", 4, 12, 20, 2, 20, 22) 
        lg.triangle("fill", 636, 12, 620, 2, 620, 22) 
        lg.rectangle("fill", 0, 25, 640, 1)
        
        -- decorations at middle
        lg.triangle("fill", 4, 220, 4, 240, 20, 230)
        lg.triangle("fill", 636, 220, 636, 240, 620, 230)
        
        -- print system name at top
        clip(24, 0, 592, 24)
        lg.printf(currentSystem.name, 0, 0, 640, "center")
        clip()
        
        -- print list of ROMs
        clip(24, 26, 592, 480)
        for i=1,#currentSystem do
            lg.print(currentSystem[i], 24, 218 + i*28 - currentSystem.game * 28)
        end
        clip()
    end
end

function state.calibrate()
    local commands = { "up", "down", "left", "right", "enter" }
    local binds = {}
    local command = 1
    
    local function check_done()
        if command > #commands then
            -- set up bindings
            for bind,name in pairs(binds) do
                eprintf("binding %s to %s\n", name, bind)
                input[name] = input["key_"..bind]
            end
            state.main()
        end
    end
    
    function love.draw()
        local lg = love.graphics
        local clip = lg.setScissor
        
        lg.printf("CALIBRATION", 0, 0, 640, "center")
        lg.printf("Press button for "..commands[command], 0, 230, 640, "center")
    end
    
    function input.key_any(key)
        binds[commands[command]] = "key_"..key
        command = command + 1
        check_done()
    end
    
    function input.joy_any(joy, type, a, b)
        local name
        if type == "button" then
            name = ("joy_%d_button_%d"):format(joy, a)
        elseif type == "axis" and b ~= "center" then
            name = ("joy_%d_axis_%d_%s"):format(joy, a, b)
        elseif type == "hat" and a ~= "c" then
            name = ("joy_%d_hat_%s"):format(joy, a)
        else
            return
        end
        binds[commands[command]] = name
        command = command + 1
        check_done()
    end
end

state.calibrate()
