local Node = require "Object" :clone("node.Node")

function Node:__init(name, parent, defaults)
    self.name = name
    self.filename = name
    self.parent = parent
    self.self = self
    self.icon = emufun.images.unknown

    if defaults then
        for k,v in pairs(defaults) do
            self[k] = v
        end
    end

    self.r,self.g,self.b = 255, 255, 255
end

function Node:__lt(rhs)
    if self._NAME == rhs._NAME then
        return self.name < rhs.name
    end
    return self._NAME < rhs._NAME
end

function Node:add(child, ...)
    if type(child) == "string" then
        return self:add(Node:new(child, self, ...))
    end
    
    table.insert(self, child)
    return child
end

function Node:add_command(name, fn, ...)
    local child = Node:new(name, self, ...)
    
    function child:run()
        return fn(child) or 0
    end
    
    self:add(child)
end

function Node:sort()
    table.sort(self)
end

function Node:path(suffix)
    if self.parent then
        local ppath = self.parent:path()
        return (#ppath > 0 and (ppath .. "/") or "")
            .. self.filename
            .. (suffix and ("/" .. suffix) or "")
    else
        return self.filename
    end
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
function Node:configure(cfg)
    -- inherit parent's configuration
    if self.parent then
        self.parent:configure(cfg)
    end

    cfg:add(self.config)
end

function Node:run()
    -- return an error message
    return new "node.Message" ("Error!", "This node doesn't support activation. Report this as a bug.", self.parent)
end

function Node:populate() end

return Node
