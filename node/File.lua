local Node = require "node.Node"
local File = Node:clone("node.File")

function File:__init(name, parent)
    Node.__init(self, name, parent)

    self.icon = emufun.images.file

    -- load configuration from disk, if present
    local cfg = new "Configuration" (self)
    self:loadConfig()
    self:configure(cfg)
    cfg:finalize()
end

function File:loadConfig()
    if self.name:match("%.emufun$") then
        self.config = assert(loadfile(self:path()))
    end
end

if love._os == "Windows" then
    function File:expandcommand(string)
        return '"' .. string:gsub("$%b{}", function(match)
            match = match:sub(3,-2)
            if type(self[match]) == "function" then
                return '"' .. tostring(self[match](self)) .. '"'
            else
                return '"' .. tostring(self[match]) .. '"'
            end
        end) .. '"'
    end
else
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
end

function File:run()
    local function exec(v)
        if type(v) == "function" then
            return v(self)
        elseif type(v) == "string" then
            local cmd = self:expandcommand(v)
            eprintf("Executing '"..cmd.."'\n")
            os.execute(cmd)
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

function File:extension()
    return self.name:match("%.([^%.]+)$")
end

return File
