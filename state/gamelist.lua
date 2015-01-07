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
    log.debug("Push: %s", peek().title)
end

local function pop()
    show()
    log.debug("Pop: %s", table.remove(views).title)
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
        log.debug("Contract: %s -> %s", peek().title, peek(1).title)
        pop()
    end
end

require "mainmenu"

local function menu()
    if not visible then
        show()
    elseif not in_menu then
        log.debug("Showing menu")
        in_menu = peek()
        push(emufun.menu)
    else
        log.debug("Hiding menu")
        while in_menu do pop() end
    end
end

-- the user has selected an entry in the list
-- the corresponding node's :run() method will return the target nodes,
-- or a number N indicating "go back N levels"
local function expand()
    local next = { peek():selected():run() }
    log.debug("Expand: %s -> %s", peek().title, peek():selected().name)
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
    peek():selected():populate(true) -- reload invalidating cache
end

local function toggle_seen()
    local node = peek():selected()
    node.attr.seen = not node.attr.seen
    node.cache:save(true)
end

local function toggle_seen_recursive()
    local node = peek():selected()
    local seen = not node.attr.seen
    local caches = {}
    node:walk(function(self)
        self.attr.seen = seen
        caches[self.cache] = true
    end)
    for cache in pairs(caches) do
        cache:save(true)
    end
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
input.bind("toggle-seen-recursive", toggle_seen_recursive)

input.bind("IDLE", hide)

input.setRepeat("up", 0.5, 0.1)
input.setRepeat("down", 0.5, 0.1)

function love.draw()
    if visible then
        peek():draw()
    end
end
