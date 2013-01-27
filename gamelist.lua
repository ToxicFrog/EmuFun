local nodes = {}

local function push(node)
    table.insert(nodes, node)
end

local function pop()
    table.remove(nodes)
end

local function peek()
    return nodes[#nodes]
end

function emufun.gamelist()
    local W,H = love.graphics.getWidth(),love.graphics.getHeight()
    
    push(emufun.root)

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
        peek():draw()
        
        -- print list of ROMs
        clip(24, 26, W-48, H)

        for i=1,#peek() do
            lg.push()
            lg.translate(24, H/2-22 + (i - peek().index) * 28)
            peek()[i]:draw()
            lg.pop()
        end
        
        clip()
    end
end

function emufun.list_prev()
    peek():prev()
end

function emufun.list_next()
    peek():next()
end

function emufun.list_contract()
    if peek().parent then
        pop()
        peek():populate()
    end
end

-- the user has selected an entry in the list
-- if it's a directory, we should scan it if necessary, then cd into it
-- if it's a file, we should find its associated .config and then launch it
function emufun.list_expand()
    push(peek():selected():run())
    peek():populate()
end
