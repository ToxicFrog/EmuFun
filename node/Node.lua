local Node = require "Object" :clone()

function Node:__init(name, parent)
    self.name = name
    self.parent = parent
    self.index = 1
    self.icon = emufun.images.unknown
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

function Node:children()
    return coroutine.wrap(function()
        for _,child in ipairs(self) do coroutine.yield(child) end
    end)
end

-- load and apply the configuration
function Node:configure(node)
    -- inherit parent's configuration
    if self.parent then
        self.parent:configure(node)
    end

    -- apply on-disk configuration, if present
    setfenv(self.config, node)
    self.config()
end

-- default configuration function is a stub
-- subclasses may load a replacement from disk
Node.config = function() end

function Node:run()
    -- return an error message
    local err = Node:new("ERROR", self.parent)
    err.icon = emufun.images.error
    function err:populate() end
    err:add_command("This node doesn't support activation. Report this as a bug.", function() end)
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
    love.graphics.print(self.displayname or self.name, 26, 0)
end

return Node
