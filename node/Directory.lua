local Node = require "node.Node"
local File = require "node.File"
local Directory = Node:clone()

function Directory:__init(name, parent)
	Node.__init(self, name, parent)

	self.icon = emufun.images.directory
end

function Directory:type()
	return "directory"
end

function Directory:run()
    -- "running" a directory just populates it and CDs into it
    self:populate()
    return self
end

function Directory:populate(...)
    -- skip dotfiles
    local function dotfile(path, item)
        return not item:match("^%.")
    end
    
    -- and anything that's not a file or directory
    local function wrongtype(path, item)
        local type = lfs.attributes(path, "mode")
        return type == "file" or type == "directory"
    end
    
    -- and configuration files, even if they don't start with "."
    local function configfile(path, item)
        return emufun.CONFIG ~= item:sub(1, #emufun.CONFIG)
    end
    
    -- clear existing population
    for i=1,#self do
        self[i] = nil
    end
    
    local filters = { dotfile, wrongtype, configfile, ... }
    
    for item in lfs.dir(self:path()) do
        local itempath = self:path().."/"..item
        
        -- ".emufun" files get loaded and run
        -- FIXME: log errors to file
        if item == ".emufun" then
            pcall(loadfile(self:path().."/.emufun"), self)
        
        else
            -- check it against all of the installed filters
            for _,filter in ipairs(filters) do
                if not filter(itempath, item) then
                    item = nil
                    break
                end
            end
            
            -- at this point, if item is non-nil, it passed every filter and
            -- should be included in the list
            if item then
            	if lfs.attributes(itempath, "mode") == "directory" then
            		self:add(Directory:new(item, self))
            	else
	                self:add(File:new(item, self))
	            end
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
