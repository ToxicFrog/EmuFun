local system

function emufun.gamelist()
    local W,H = love.graphics.getWidth(),love.graphics.getHeight()
    
    system = emufun.root
    system.dir = system

    function love.draw()
        local lg = love.graphics
        local clip = lg.setScissor

        lg.setColor(255, 255, 255)
        
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
            lg.push()
            lg.translate(24, H/2-22 + (i - system.dir.index) * 28)
            system.dir[i]:draw()
            lg.pop()
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
    do return end
    emufun.root:prev()
    system = emufun.root[emufun.root.index]
    system:populate()
end

function emufun.next_system()
    do return end
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
