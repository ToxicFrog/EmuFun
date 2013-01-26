local node

function emufun.gamelist()
    local W,H = love.graphics.getWidth(),love.graphics.getHeight()
    
    node = emufun.root

    function love.draw()
        local lg = love.graphics
        local clip = lg.setScissor

        lg.setColor(255, 255, 255)
        
        -- decorations at top
        lg.rectangle("fill", 0, 25, W, 2)
        
        -- decorations at middle
        lg.triangle("fill", 4, H/2-20, 4, H/2, 20, H/2-10)
        lg.triangle("fill", W-4, H/2-20, W-4, H/2, W-20, H/2-10)
        
        -- print system name at top
        node:draw()
        
        -- print list of ROMs
        clip(24, 26, W-48, H)

        for i=1,#node do
            lg.push()
            lg.translate(24, H/2-22 + (i - node.index) * 28)
            node[i]:draw()
            lg.pop()
        end
        
        clip()
    end
end

function emufun.list_prev()
    node:prev()
end

function emufun.list_next()
    node:next()
end

function emufun.list_contract()
    if node.parent then
        node = node.parent
        node:populate()
    end
end

-- the user has selected an entry in the list
-- if it's a directory, we should scan it if necessary, then cd into it
-- if it's a file, we should find its associated .config and then launch it
function emufun.list_expand()
    node = node:selected():run()
    node:populate()
end
