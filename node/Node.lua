local Node = require "Object" :clone()

Node.emufun = emufun

function Node:__init(name, parent)
    self.name = name
    self.parent = parent
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

function Node:type()
    return lfs.attributes(self:path(), "mode")
end

function Node:children()
    return coroutine.wrap(function()
        for _,child in ipairs(self) do coroutine.yield(child) end
    end)
end

-- default configuration function is a stub
-- subclasses may load a replacement from disk
Node.config = function() end

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

function Node:run()
    -- return an error message
    return new "node.Message" ("Error!", "This node doesn't support activation. Report this as a bug.", self.parent)
end

function Node:draw()
    love.graphics.draw(self.icon, 0, 0)
    love.graphics.print(self.displayname or self.name, 26, 0)
end

function Node:populate() end

return Node
