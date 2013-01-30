local Node = require "node.Node"
local File = Node:clone("node.File")

function File:__init(name, parent)
    Node.__init(self, name, parent)

    self.icon = emufun.images.file

    --self:loadConfig()
    self:configure(self)
end

function File:loadConfig()
    if self.name:match("%.emufun$") then
        self.config = assert(loadfile(self:path()))
    end
end

function File:run()
    -- the configuration file should define a command to execute
    -- if not, we fall through to the error
    if self.command then
        eprintf("STUB: %s %s\n", tostring(self:path()), tostring(self.command))
        if type(self.command) == "function" then
            self:command()
        end
        return self.parent
    end
    
    return new "node.Message" ("Error!", "No configuration available to execute this file", self.parent)
end

return File
