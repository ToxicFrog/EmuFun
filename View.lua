local Object = require "Object"
local View = Object:clone()

-- a view of one or more nodes in the media library
-- a view has a title and icon (displayed at the top), and a list of nodes
-- (displayed in the main window) which the user can scroll through. It
-- also needs to remember where it is in that list so that it can recall
-- it when visited later.
function View:__init(icon, title, ...)
	self.index = 1
	self.icon = icon
	self.title = title
    self.nodes = {...}

    self:populate(self.nodes)
end

function View:populate(nodes)
    self.list = {}
    for _,node in ipairs(nodes) do
        for child in node:children() do
            if not child.hidden then
                table.insert(self.list, child)
            end
        end
    end
end

function View:reload()
    for _,node in ipairs(self.nodes) do
        if node.populate then
            node:populate(true)
        else
            log.error("In View:reload(): attempt to populate a file (%s)", node:path())
        end
    end
    self:populate(self.nodes)
end

local W,H = love.graphics.getWidth(),love.graphics.getHeight()
local LH = math.floor(H/emufun.config.lines)

local function atLine(line)
    local lg = love.graphics

    lg.push()
    lg.translate(0, math.floor(H/emufun.config.lines * line))
end

local function doneLine()
    love.graphics.pop()
end

function View:draw()
	local lg = love.graphics
	local clip = lg.setScissor

    atLine(0)
        lg.setColor(32, 32, 32)
        lg.rectangle("fill", 0, 0, W, LH)
        lg.setColor(255, 255, 255)
        lg.draw(self.icon, 0, 0, 0, LH/self.icon:getWidth(), LH/self.icon:getHeight())
        lg.print(self.title, LH + 2, 0)
    doneLine()

    local padding = math.floor(LH * 0.2)
    local half = math.floor(LH/2)

    for i=1,emufun.config.lines do
        local index = i - math.floor(emufun.config.lines/2) + self.index
        local node = self.list[index]
        if node then
            atLine(i)
            if index == self.index then
                self:drawNode(node, 128, 255, 128)
                lg.polygon("fill",
                    padding, padding,
                    padding, LH-padding,
                    LH-padding, half)
            else
                self:drawNode(node)
            end
            doneLine()
        end
    end
end

function View:prev()
    self.index = (self.index - 2) % #self.list + 1
end

function View:next()
    self.index = self.index % #self.list + 1
end

function View:selected()
	return self.list[self.index]
end

-- hacky workaround for love.graphics barfing on some things that should be valid utf8
function love.graphics.safeprint(str, ...)
    local ok = pcall(love.graphics.print, str, ...)
    if ok then return end

    log.error("Error displaying title: %s", tostring(str))
    str = str:gsub("[^%w%s%p]", "?")
    log.error("Falling back to: %s", tostring(str))
    ok = pcall(love.graphics.print, str, ...)
    if ok then return end

    love.graphics.print("[corrupted filename]", ...)
end

-- draw this node with an optional colour mask
function View:drawNode(node, r, g, b)
    local min = math.min
    local _r,_g,_b  = node:colour()
    r = r and min(r, _r) or _r
    g = g and min(g, _g) or _g
    b = b and min(b, _b) or _b
    love.graphics.setColor(r,g,b)
    love.graphics.draw(node.icon, LH, 0, 0, LH/node.icon:getWidth(), LH/node.icon:getHeight())
    love.graphics.safeprint(node.name, 2*LH+2, 0)
end

return View
