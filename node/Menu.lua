local Node = require "node.Node"
local Menu = Node:clone("node.Menu")

function Menu:__init(title, ...)
    Node.__init(self, title, nil)
    self.icon = emufun.images.nothing
    self.name = title
    print("menu", title)

    local argv = {...}
    for i=1,#argv,2 do
      self:add_command(argv[i], argv[i+1], { icon = emufun.images.nothing })
    end
end

return Menu
