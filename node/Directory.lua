local Node = require "node.Node"
local File = require "node.File"
local Configuration = require "Configuration"
local Directory = Node:clone("node.Directory")

function Directory:__init(name, parent)
	Node.__init(self, name, parent)

	self.icon = emufun.images.directory

    -- load configuration from disk, if present
    local cfg = new "Configuration" (self)
    self:loadConfig()
	self:configure(cfg)
    cfg:finalize()
end

function Directory:run()
    -- "running" a directory just populates it and CDs into it
    self:populate()

    if #self == 0 then
        return new "node.Message" (self.name, "Directory is empty!", self.parent)
    end

    return self
end

function Directory:loadConfig()
	local config = loadfile(self:path() .. "/.emufun")

	self.config = config or self.config
end

function Directory:populate(...)
    -- clear existing population
    for i=1,#self do
        self[i] = nil
    end
    
    for item in lfs.dir(self:path()) do
        local itempath = self:path().."/"..item
        
        -- create a node for it
        local node
        if lfs.attributes(itempath, "mode") == "directory" then
            node = Directory:new(item, self)
        else
            node = File:new(item, self)
        end

        if not node.hidden then
            self:add(node)
        end
    end
    
    self:sort()
end

return Directory
