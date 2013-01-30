local Node = require "node.Node"
local File = Node:clone("node.File")

function File:__init(name, parent)
    Node.__init(self, name, parent)

    self.icon = emufun.images.file

    self:loadConfig()
    self:configure(self)
end

function File:loadConfig()
    if self.name:match("%.emufun$") then
        self.config = assert(loadfile(self:path()))
    end
end

function File:run()
    local function exec(v)
        if type(v) == "function" then
            return v(self)
        elseif type(v) == "string" then
            os.execute(v)
            return false
        elseif type(v) == "table" then
            local rv
            for _,command in ipairs(v) do
                rv = exec(v)
            end
            return rv
        else
            return new "node.Message" ("Error executing commands for " .. self:path(), "Unknown command type " .. type(v))
        end
    end

    -- the configuration file should define a command to execute
    -- if not, we fall through to the error
    if self.execute then
        return exec(self.execute) or self.parent
    end
    
    return new "node.Message" ("Error!", "No configuration available to execute this file", self.parent)
end

return File
