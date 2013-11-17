local Node = require "node.Node"
local File = require "node.File"
local Configuration = require "Configuration"
local Directory = Node:clone("node.Directory")

Directory.icon = emufun.images.directory

function Directory:__init(...)
	Node.__init(self, ...)

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
        return new "node.Message" { name = self.name, message = "Directory is empty!", parent = self.parent }
    end

    return self
end

function Directory:loadConfig()
    for _,name in ipairs(emufun.config.cfg_names) do
        local config = loadfile(self:path(name))
        if config then
            self.config = config
            break
        end
    end
end

function Directory:populate(...)
    -- clear existing population
    for i=1,#self do
        self[i] = nil
    end
    
    for item in lfs.dir(self:path()) do
        -- create a node for it
        local node
        if lfs.attributes(self:path(item), "mode") == "directory" then
            node = new "node.Directory" { name = item, parent = self }
        else
            node = new "node.File" { name = item, parent = self }
        end

        if not node.hidden then
            self:add(node)
        end
    end
    
    self:sort()
end

function Directory:dir()
    return self:path()
end

return Directory
