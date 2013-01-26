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
    -- if the game starts with "--!emufun", it's an emufun script and should
    -- be loaded and run directly
    if io.readn(self:path(), 9) == "--!emufun" then
        pcall(loadfile(self:path()), self)
        return self.parent
    end
    
    -- running a game executes it with emufun.launch and returns its containing
    -- directory
    if self:find_config() then
        emufun.launch(emufun.root:path(), self:path(), self:find_config())
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
