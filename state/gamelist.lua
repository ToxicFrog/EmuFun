local views = {}
local view

local visible
local function hide() visible = false end
local function show() visible = true end

local function push(icon, title, node, ...)
    show()
    table.insert(views, new "View" (icon or node.icon, title or node:path(), node, ...))
    view = views[#views]
end

local function pop()
    show()
    table.remove(views)
    view = views[#views]
end

local function prev()
    show()
    view:prev()
end

local function next()
    show()
    view:next()
end

local function contract()
    show()
    if #views > 1 then
        pop()
    end
end

local kitten_mode = false

local function kitten_toggle(self)
    kitten_mode = not kitten_mode
    input.keyboard_enabled = not kitten_mode
    self.name = "Toggle Kitten Mode [%s]" % (kitten_mode and "ON" or "OFF")
end

local function menu()
    show()
    hidden = false

    if view.icon ~= emufun.images.mainmenu then
        push(nil, nil, new "node.Menu" {
            name = "Main Menu";
            commands = {
                { name = "Toggle Kitten Mode [%s]" % (kitten_mode and "ON" or "OFF"), run = kitten_toggle };
                { name = "Quit EmuFun", run = emufun.quit };
            };
        })
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
    elseif #next > 0 then
        push(nil, nil, unpack(next))
    end
    love.event.clear()
    timer.reset("IDLE")
end

local root, library = ...

push(nil, nil, root)
push(nil, nil, unpack(library))

input.bind("up", prev)
input.bind("down", next)
input.bind("left", contract)
input.bind("right", expand)
input.bind("menu", menu)

input.bind("IDLE", hide)

input.setRepeat("up", 0.5, 0.1)
input.setRepeat("down", 0.5, 0.1)

function love.draw()
    if visible then
        view:draw()
    end
end
