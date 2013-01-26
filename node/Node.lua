local Node = require "Object" :clone()

function Node:__init(name, parent)
    self.name,self.parent = name,parent
    self.index = 1

    if self:type() == "directory" then
        self.icon = emufun.images.directory
    else
        self.icon = emufun.images.file
    end
end

function Node:add(child)
    if type(child) == "string" then
        return self:add(Node:new(child, self))
    end
    
    table.insert(self, child)
    return child
end

function Node:add_command(name, fn)
    local child = Node:new(name, self)
    
    function child:run()
        return fn(child) or child.parent
    end
    
    self:add(child)
end

function Node:sort()
    table.sort(self, function(lhs, rhs)
        -- directories go first
        if lhs:type() ~= rhs:type() then
            return lhs:type() == "directory"
        else
            -- otherwise go in name order
            return lhs.name < rhs.name
        end
    end)
end

function Node:path()
    if self.parent then
        return self.parent:path().."/"..self.name
    else
        return self.name
    end
end

function Node:prev()
    self.index = (self.index - 2) % #self + 1
end

function Node:next()
    self.index = self.index % #self + 1
end

function Node:type()
    return lfs.attributes(self:path(), "mode")
end

function Node:selected()
    return self[self.index]
end

function Node:populate(...)
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

function Node:children()
    return coroutine.wrap(function()
        for _,child in ipairs(self) do coroutine.yield(child) end
    end)
end

function Node:find_config()
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

function Node:run()
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

function Node:draw()
    if self.parent and self.parent:selected() == self then
        love.graphics.setColor(128, 255, 128)
    else
        love.graphics.setColor(255, 255, 255)
    end

    love.graphics.draw(self.icon, 0, 0)
    love.graphics.print(self.name, 26, 0)
end

return Node