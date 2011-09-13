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

function node:populate()
    if self.populated then return end
    
    for item in lfs.dir(self:path()) do
        if not (item:match("^%.") or item:match("%.config$")) then
            self:add(item)
        elseif item == ".emufun" then
            pcall(loadfile(self:path().."/.emufun"), self)
        end
    end
    
    self:sort()
    self.populated = true
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
    if exists(self.parent:path().."/.config."..self.name) then
        return self.parent:path().."/.config."..self.name
    end
    
    -- if not, work our way up the directory tree looking for a ".config" file
    -- in each directory
    while self.parent do
        self = self.parent
        if exists(self:path().."/.config") then
            return self:path().."/.config"
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
