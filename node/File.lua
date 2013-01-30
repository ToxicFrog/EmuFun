local Node = require "node.Node"
local File = Node:clone("node.File")

function File:__init(name, parent)
    Node.__init(self, name, parent)

    self.icon = emufun.images.file

    self:loadConfig()
    self:configure(self)
end

function File:loadConfig()
    if self.name:match("%.emufun$") then
        self.config = assert(loadfile(self:path()))
    end
end

function File:expandcommand(string)
    local function escape(string)
        return (string:gsub("'", [['\'']]))
    end
    return (string:gsub("$%b{}", function(match)
        match = match:sub(3,-2)
        if type(self[match]) == "function" then
            return "'" .. escape(tostring(self[match](self))) .. "'"
        else
            return "'" .. escape(tostring(self[match])) .. "'"
        end
    end))
end

function File:run()
    local function exec(v)
        if type(v) == "function" then
            return v(self)
        elseif type(v) == "string" then
            eprintf("Executing '"..self:expandcommand(v).."'\n")
            os.execute(self:expandcommand(v))
            return false
        elseif type(v) == "table" then
            local rv
            for _,command in ipairs(v) do
                rv = exec(v)
            end
            return rv
        else
            return new "node.Message" ("Error executing commands for " .. self:path(), "Unknown command type " .. type(v))
        end
    end

    -- the configuration file should define a command to execute
    -- if not, we fall through to the error
    if self.execute then
        if emufun.config.fullscreen then
            love.graphics.toggleFullscreen()
        end

        local rv = exec(self.execute) or 0

        if emufun.config.fullscreen then
            love.graphics.toggleFullscreen()
        end
        love.event.clear()
        return rv
    end
    
    return new "node.Message" ("Error!", "No configuration available to execute this file", self.parent)
end

return File
