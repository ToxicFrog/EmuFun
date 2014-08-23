local views = {}

local visible
local in_menu = false
local function hide() visible = false end
local function show() visible = true end

local function peek(n)
    return views[#views - (n or 0)]
end

local function push(node, ...)
    show()
    table.insert(views, new "View" (node.icon, node:path(), node, ...))
    LOG.DEBUG("Push: %s", peek().title)
end

local function pop()
    show()
    LOG.DEBUG("Pop: %s", table.remove(views).title)
    if peek() == in_menu then
        in_menu = false
    end
end

local function prev()
    show()
    peek():prev()
end

local function next()
    show()
    peek():next()
end

local function contract()
    show()
    if #views > 1 then
        LOG.DEBUG("Contract: %s -> %s", peek().title, peek(1).title)
        pop()
    end
end

require "mainmenu"
local cache = require "cache"

local function menu()
    if not visible then
        show()
    elseif not in_menu then
        LOG.DEBUG("Showing menu")
        in_menu = peek()
        push(emufun.menu)
    else
        LOG.DEBUG("Hiding menu")
        while in_menu do pop() end
    end
end

-- the user has selected an entry in the list
-- the corresponding node's :run() method will return the target nodes,
-- or a number N indicating "go back N levels"
local function expand()
    local next = { peek():selected():run() }
    LOG.DEBUG("Expand: %s -> %s", peek().title, peek():selected().name)
    if type(next[1]) == "number" then
        for i=1,next[1] do
            contract()
        end
    elseif #next > 0 then
        push(unpack(next))
    end
    love.event.clear()
    timer.reset("IDLE")
end

local function reload()
    contract()
    expand()
end

local function toggle_seen()
    local node = peek():selected()
    node.cache.flags.seen = not node.cache.flags.seen
    cache.save()
end

local root, library = ...

push(root)
push(unpack(library))

input.bind("up", prev)
input.bind("down", next)
input.bind("left", contract)
input.bind("right", expand)
input.bind("menu", menu)
input.bind("reload", reload)
input.bind("toggle-seen", toggle_seen)

input.bind("IDLE", hide)

input.setRepeat("up", 0.5, 0.1)
input.setRepeat("down", 0.5, 0.1)

function love.draw()
    if visible then
        peek():draw()
    end
end
