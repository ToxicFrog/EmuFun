local Node = require "node.Node"
local Menu = Node:clone("node.Menu")

Menu.icon = emufun.images.nothing

function Menu:__init(...)
    Node.__init(self, ...)

    for _,v in ipairs(self.commands) do
      v.icon = v.icon or emufun.images.nothing
      self:add_command(v)
    end
end

return Menu