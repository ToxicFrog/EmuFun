local Node = require "node.Node"
local Message = Node:clone()

function Message:__init(name, message, parent)
    Node.__init(self, name, parent)

    self.icon = emufun.images.error

    self:add_command(message, function() return parent end)
end

return Message
