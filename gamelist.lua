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

function emufun.gamelist()
    push(nil, "Media Library", unpack(emufun.library))

    input.bind("up", emufun.list_prev)
    input.bind("down", emufun.list_next)
    input.bind("left", emufun.list_contract)
    input.bind("right", emufun.list_expand)

    function love.draw()
        view:draw()
    end
end

function emufun.list_prev()
    view:prev()
end

function emufun.list_next()
    view:next()
end

function emufun.list_contract()
    if #views > 1 then
        pop()
    end
end

-- the user has selected an entry in the list
-- if it's a directory, we should scan it if necessary, then cd into it
-- if it's a file, we should find its associated .config and then launch it
function emufun.list_expand()
    local next = view:selected():run()
    if type(next) == "number" then
        for i=1,next do
            emufun.list_contract()
        end
    else
        push(nil, nil, next)
    end
end
