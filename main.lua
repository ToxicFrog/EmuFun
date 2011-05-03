local systems = {}
local configs = {}

local currentSystemIndex
local currentSystem

function love.load()
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
    
    --love.graphics.setFont("LiberationMono-Bold.ttf", 24)
    love.graphics.setFont(24)
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.setCaption("EmuFun")
    love.mouse.setVisible(false)
end

local key = {}

function key.q()
    love.event.push "q"
end

function key.up()
    currentSystem.game = (currentSystem.game - 2) % #currentSystem + 1
end

function key.down()
    currentSystem.game = currentSystem.game % #currentSystem + 1
end

function key.left()
    currentSystemIndex = (currentSystemIndex - 2) % #systems + 1
    currentSystem = systems[currentSystemIndex]
end

function key.right()
    currentSystemIndex = currentSystemIndex % #systems + 1
    currentSystem = systems[currentSystemIndex]
end

function key.enter()
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
    
    key.q()
end
key["return"] = key.enter

function love.keypressed(name, num)
	if key[name] then
	    key[name]()
	end
end

function love.update(dt)
    love.timer.sleep(33 - (dt*1000))
end

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
