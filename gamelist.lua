local views = {}
local view

local function push(icon, title, node, ...)
    table.insert(views, new "View" (icon or node.icon, title or node.name, node, ...))
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
-- if it's a directory, we should scan it if necessary, then cd into it
-- if it's a file, we should find its associated .config and then launch it
local function expand()
    local next = view:selected():run()
    if type(next) == "number" then
        for i=1,next do
            contract()
        end
    else
        push(nil, nil, next)
    end
end

function emufun.gamelist()
    push(nil, "Media Library", unpack(emufun.library))

    input.bind("up", prev)
    input.bind("down", next)
    input.bind("left", contract)
    input.bind("right", expand)

    input.setRepeat("up", 0.5, 0.1)
    input.setRepeat("down", 0.5, 0.1)

    function love.draw()
        view:draw()
    end
end
