node = {}

node.metatable = { __index = node }

function node.new(name, parent)
    return setmetatable({ name = name, parent = parent, index = 1 }, node.metatable)
end

function node:add(child)
    if type(child) == "string" then
        return self:add(node.new(child, self))
    end
    
    table.insert(self, child)
    return child
end

function node:add_command(name, fn)
    local child = node.new(name, self)
    
    function child:run()
        fn(child)
        return child.parent
    end
    
    self:add(child)
end

function node:sort()
    table.sort(self, function(lhs, rhs) return lhs.name < rhs.name end)
end

function node:path()
    if self.parent then
        return self.parent:path().."/"..self.name
    else
        return self.name
    end
end

function node:prev()
    self.index = (self.index - 2) % #self + 1
end

function node:next()
    self.index = self.index % #self + 1
end

function node:type()
    return lfs.attributes(self:path(), "mode")
end

function node:selected()
    return self[self.index]
end

function node:populate(...)
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
                self:add(item)
            end
        end
    end
    
    self:sort()
    
    -- bring index within bounds
    if self.index > #self then
        self.index = 1
    end
end

function node:children()
    return coroutine.wrap(function()
        for _,child in ipairs(self) do coroutine.yield(child) end
    end)
end

function node:find_config()
    local function exists(path)
        return lfs.attributes(path, "mode") == "file"
    end
    
    -- check to see if .config.$ROM exists
    if exists(self.parent:path().."/"..emufun.CONFIG..self.name) then
        return self.parent:path().."/"..emufun.CONFIG..self.name
    end
    
    -- if not, work our way up the directory tree looking for a ".config" file
    -- in each directory
    while self.parent do
        self = self.parent
        if exists(self:path().."/"..emufun.CONFIG) then
            return self:path().."/"..emufun.CONFIG
        end
    end
    
    return nil
end

function node:run()
    -- "running" a directory just populates it and CDs into it
    if self:type() == "directory" then
        self:populate()
        return self
    end
    
    -- if the game starts with "--!emufun", it's an emufun script and should
    -- be loaded and run directly
    if io.readn(self:path(), 9) == "--!emufun" then
        pcall(loadfile(self:path()), self)
        return self.parent
    end
    
    -- running a game executes it with emufun.launch and returns its containing
    -- directory
    emufun.launch(emufun.root:path(), self:path(), self:find_config())
    return self.parent
end
