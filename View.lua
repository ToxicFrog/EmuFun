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
	self.list = {}

	for _,node in ipairs {...} do
		for child in node:children() do
			table.insert(self.list, child)
		end
	end
end

function View:draw()
    local W,H = love.graphics.getWidth(),love.graphics.getHeight()
    
	local lg = love.graphics
	local clip = lg.setScissor

	lg.setColor(255, 255, 255)

    -- decorations at top
    lg.rectangle("fill", 0, 25, W, 2)
        
    -- decorations at middle
    lg.triangle("fill", 4, H/2-20, 4, H/2, 20, H/2-10)
    lg.triangle("fill", W-4, H/2-20, W-4, H/2, W-20, H/2-10)
        
    -- print system name at top
    lg.draw(self.icon, 0, 0)
    lg.print(self.title, 26, 0)
        
    -- print list of ROMs
    clip(24, 26, W-48, H)

	for i,node in ipairs(self.list) do
        lg.push()
        lg.translate(24, H/2-22 + (i - self.index) * 28)

        if i == self.index then
        	lg.setColor(128, 255, 128)
        end

        node:draw()
    	lg.setColor(255, 255, 255)

        lg.pop()
    end

    clip()
end

function View:prev()
    self.index = (self.index - 2) % #self.list + 1
end

function View:next()
    self.index = self.index % #self.list + 1
end

return View
