local Node = require "node.Node"
local File = Node:clone()

function File:__init(name, parent)
    Node.__init(self, name, parent)

    self.icon = emufun.images.file
end

function File:type()
    return "file"
end

function File:run()
    -- the configuration file should define a command to execute
    -- if not, we fall through to the error
    if self.command then
        eprintf("STUB: %s %s\n", tostring(self:path()), tostring(self.command))
        return self.parent
    end
    
    -- return an error message
    local err = Node:new("ERROR", self.parent)
    err.icon = emufun.images.error
    function err:populate() end
    err:add_command("Couldn't find configuration file!", function() end)
    err[1].parent = self.parent
    return err
end

return File
