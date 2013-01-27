local Node = require "node.Node"
local File = require "node.File"
local Directory = Node:clone()

function Directory:__init(name, parent)
	Node.__init(self, name, parent)

	self.icon = emufun.images.directory

    -- load configuration from disk, if present
    self:loadConfig()
	self:configure(self)
end

function Directory:type()
	return "directory"
end

function Directory:run()
    -- "running" a directory just populates it and CDs into it
    self:populate()
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
        
        -- ".emufun" files get loaded and run
        -- FIXME: log errors to file
        if item == ".emufun" then
            pcall(loadfile(self:path().."/.emufun"), self)
        
        else
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
    end
    
    self:sort()
    
    -- bring index within bounds
    if self.index > #self then
        self.index = 1
    end
end

return Directory
