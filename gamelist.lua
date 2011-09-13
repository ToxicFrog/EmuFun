local system

function emufun.gamelist()
    local W,H = love.graphics.getWidth(),love.graphics.getHeight()
    
    system = emufun.root[1]
    for sys in emufun.root:children() do
        sys.dir = sys
    end

    function love.draw()
        local lg = love.graphics
        local clip = lg.setScissor
        
        -- decorations at top
        lg.triangle("fill", 4, 12, 20, 2, 20, 22) 
        lg.triangle("fill", W-4, 12, W-20, 2, W-20, 22) 
        lg.rectangle("fill", 0, 25, W, 2)
        
        -- decorations at middle
        lg.triangle("fill", 4, H/2-20, 4, H/2, 20, H/2-10)
        lg.triangle("fill", W-4, H/2-20, W-4, H/2, W-20, H/2-10)
        
        -- print system name at top
        clip(24, 0, W-48, 24)
        lg.printf(system.name, 0, 0, W, "center")
        clip()
        
        -- print list of ROMs
        clip(24, 26, W-48, H)
        for i=1,#system.dir do
            lg.print(system.dir[i].name, 24, H/2-22 + i*28 - system.dir.index * 28)
        end
        
        -- print currently selected ROM
        -- this can be nil if the directory is empty
        if system.dir[system.dir.index] then
            lg.setColor(128, 255, 128)
            lg.print(system.dir[system.dir.index].name, 24, H/2-22)
            lg.setColor(255, 255, 255)
        end
        
        clip()
    end
end

function emufun.prev_game()
    system.dir:prev()
end

function emufun.next_game()
    system.dir:next()
end

function emufun.prev_system()
    emufun.root:prev()
    system = emufun.root[emufun.root.index]
    system:populate()
end

function emufun.next_system()
    emufun.root:next()
    system = emufun.root[emufun.root.index]
    system.dir:populate()
end

function emufun.up()
    if system.dir ~= system then
        system.dir = system.dir.parent
        system.dir:populate()
    end
end

-- the user has selected an entry in the list
-- if it's a directory, we should scan it if necessary, then cd into it
-- if it's a file, we should find its associated .config and then launch it
function emufun.down()
    system.dir = system.dir:selected():run()
    system.dir:populate()
end
