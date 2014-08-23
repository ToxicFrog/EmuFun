local Node = require "Object" :clone("node.Node")

Node.icon = emufun.images.unknown

function Node:__init(props)
    if props then
        for k,v in pairs(props) do
            self[k] = v
        end
    end

    assert(self.name, "Node created without a name")

    self.filename = self.filename or self.name
end

function Node:colour()
    return 255, 255, 255
end

function Node:__lt(rhs)
    if self._NAME == rhs._NAME then
        return self.name < rhs.name
    end
    return self._NAME < rhs._NAME
end

function Node:add(child)
    if type(child) == "string" then
        return self:add(Node:new { name = child, parent = self })
    end

    table.insert(self, child)
    return child
end

function Node:add_command(props)
    local child = new "node.Node" (props)
    local run = child.run

    child.run = function(...) return run(...) or 0 end

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

function Node:walk(f)
    for child in self:children() do
        f(child)
    end
    return f(self)
end

function Node:run()
    -- return an error message
    return new "node.Message" { name = "Error!", message = "This node doesn't support activation. Report this as a bug.", parent = self.parent }
end

function Node:populate() end

return Node
