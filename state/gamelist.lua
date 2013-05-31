local views = {}
local view

local function push(icon, title, node, ...)
    table.insert(views, new "View" (icon or node.icon, title or node:path(), node, ...))
    view = views[#views]
end

local function pop()
    table.remove(views)
    view = views[#views]
end

local function prev()
    view:prev()
end

local function next()
    view:next()
end

local function contract()
    if #views > 1 then
        pop()
    end
end

-- the user has selected an entry in the list
-- the corresponding node's :run() method will return the target nodes,
-- or a number N indicating "go back N levels"
local function expand()
    local next = { view:selected():run() }
    if type(next[1]) == "number" then
        for i=1,next[1] do
            contract()
        end
    else
        push(nil, nil, unpack(next))
    end
    love.event.clear()
end

local root, library = ...

push(nil, nil, root)
push(nil, nil, unpack(library))

input.bind("up", prev)
input.bind("down", next)
input.bind("left", contract)
input.bind("right", expand)

input.setRepeat("up", 0.5, 0.1)
input.setRepeat("down", 0.5, 0.1)

function love.draw()
    view:draw()
end
