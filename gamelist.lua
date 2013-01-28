local views = {}
local view

local function push(node, icon, title)
    table.insert(views, new "View" (icon or node.icon, title or node.name, node))
    view = views[#views]
end

local function pop()
    table.remove(views)
    view = views[#views]
end

function emufun.gamelist()
    push(emufun.root, nil, "Media Library")

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
    push(view.list[view.index]:run())
end
