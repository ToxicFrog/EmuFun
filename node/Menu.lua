local Node = require "node.Node"
local Menu = Node:clone("node.Menu")

Menu.icon = emufun.images.nothing

function Menu:__init(...)
    Node.__init(self, ...)

    for _,v in ipairs(self.commands) do
        self:add(v)
    end
end

function Menu:sort() end

return Menu
