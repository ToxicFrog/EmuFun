local Node = require "node.Node"
local Message = Node:clone()

Message.icon = emufun.images.error

function Message:__init(...)
    Node.__init(self, ...)

    self:add_command { name = self.message, run = function() return 1 end }
end

return Message
